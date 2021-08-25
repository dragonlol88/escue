<h1 align="center">ElasticSearch resCUE(ESCUE)</h1>

<p align="center">Elasticsearch terminal interface manager</p>

<h2>Description</h2>
Elasticsearch is a big data distributed search system. It supports very diverse search functions and shows fast search speed using inverted index. 
However, Managing elasticsearch cluster has some annoying works which are installation on each sever or neccessary files syncronization or to restart es etc... . 
So, ESCUE is motivated from that works and supports some functions that can solve this annoying and uncomportable works at the toy levels.
<br />
<br />
ESCUE is linux terminal interface application and in order to manage distributed system across multiple servers, ESCUE requires the identity file 
containing ssh private key in almost any tasks. So I recommend you before using, that register ssh public key on multiple severs where node will 
be installed first. Otherwise, in almost tasks, identity file option must be speicified. If you discover yourself typing -i ......... in the terminal, 
you might give up using ESCUE.


<h2>OS dependencies</h2>
I develop ESCUE in 'centos' operating system. So....I just wish so much that ESCUE can work other linux platforms.

<h2>Shell dependencies</h2>

ESCUE is developed using shell programming as full power(purity 100%). Because I don't know, don't ask me that reason. 
Also, I just hope ......... that...... working....in other shell and versions. sorry...

shell: bash <br />
version: 4.2.46(2)-release <br />

ESCUE is using powerful tools supported from bash shell for dealing with files ...<br />

sed,
mktemp,
column,
paste

If ESCUE can not work in your environment, first check that tools installed. If not then....
you consider typing 'rm -rf escue'..


<h2>Installation</h2>
First, git clone

```shell script
$ git clone <url>
```

Second, move escue

```shell script
$ cd escue
$ bash config/install.sh
```

<h2>Uses</h2>
Assuming that the ssh public key has been registered on the remote severs where nodes will be installed. 
If you don't know what to do, see this [tutorial](https://opentutorials.org/module/432/3742)

Also, because the escue only does support archive installation, elasticsearch must be downloaded from 
[archive](https://www.elastic.co/kr/downloads/elasticsearch)

<br /><br />
First you must create cluster.<br />

```shell script
$ escue cluster create sunny
```

if success, sunny cluster will be created. Check clusters

```shell script
$ escue cluster list
```

Next, create node, and typing the elasticsearch configuration and server information to connect remote sever.

```shell script
$ escue node create -c sunny node-1
```

Then the following questions appear.
```shell script
# Roles setting
# comma seperation
Enter node roles: master,data

# Paths setting
Enter node data path: /data/es/data
Enter node logs path: /data/es/logs

# Networking setting
Enter node host: 192.168.0.230
Enter node http port: 9200
Enter node transport port: 9300

# seed_hosts setting
# comma seperation
Enter node seed hosts: 192.168.0.232:9300,192.168.0.234,seeds.mydomain.com

# Cluster initial master nodes
Enter node initial master nodes: node-1,node-2

# Server setting
Enter server host: 192.168.0.230
Enter server user name: es-user
Enter server install path: /home/es-user/install

Enter config path: # Skip typing input(just press Enter)  

# JVM setting
Enter heap size: 26g
```

Check  sunny cluster's node list
```shell script
$ escue node list -c sunny
```
or check all cluster's node list
```shell script
$ escue node list
```
<h3>Install nodes across multiple servers</h3>

If you follow well so far, let's install nodes to multiple severs.


* Intall nodes across cluster

```shell script
$ escue cluster install -s ./elasticsearch-7.13.4-linux-x86_64.tar.gz sunny
```
if you want to install es in aws, using pem file to connect with multiple severs.

```shell script
$ escue cluster install -s ./elasticsearch-7.13.4-linux-x86_64.tar.gz -i ~/.ssh/aws.pem sunny
```

* Install node on single remote server

```shell script
$ escue node install -s ./elasticsearch-7.13.4-linux-x86_64.tar.gz -c sunny node-1
```


<h3>Remove nodes across multiple servers</h3>
If there is a problem with a cluster and you have to kill all the nodes in cluster, use the 'remove' command.<br /><br />

```shell script
$ escue cluster remove sunny
```

However, If there is a problem only with a node, use 'node' management command

```shell script
$ escue node remove -c sunny node-1 
```

**Warning**: Because 'remove' command completely clear nodes completely including everything data and logs, If problems just are related with configurations 
or synchronization, modify configuration, then use 'restart command'. 

<h3>Modify node configurations</h3>
The escue manages several configurations related with elasticsearch and server as file. The configurations related to elasticsearch are elasticsearch.yml and jvm.options. 
Also, the configuration related to remote server is server files.<br /><br />

Because it is difficult to modify configurations as terminal interface and very tired to typing the command in terminal, escue is made to directly edit configuration. <br />

* To modify elasticsearch.yml 

```shell script
$ escue node mod -c sunny --config yml node-1
```

* To modify jvm.options

```shell script
$ escue node mod -c sunny --config jvm node-1
```

* To modify servers

```shell script
$ escue node mod -c sunny --config server node-1
```

<h3>Synchronize configuration and files</h3>
If you modify configurations of any node, the changes must be synchronized. So, escue supports synchronization command 'sync'. The Elasticsearch synchronization  
process has some complex steps which ensure the success of the previous steps. Also, If a synchronization process was not successful and applied, elasticsearch 
engine will raise errors and services using this es engine wil failed. Because of these difficulties, only escue's 'sync' transmits the files related to the 
configuration, but not applied. <br /><br />

* elasticsearch.yml synchronization

```shell script
$ escue sync yml -n node-1 sunny
```

* jvm.options synchronization

```shell script
$ escue sync jvm -n node-1 sunny
```

* files related with analysis synchronization

```shell script
$ escue sync ana -s synonyms.txt -t escue-project sunny
```

Because the base target directory is config/analysis, If -t(target directory) is specified, then the file will be saved in base/target directory.
From above example, the synonyms.txt will be saved in config/analysis/escue-project.<br />
 
If -t is not specified, default save directory will be config/analysis.

```shell script
$ escue sync ana -s synonyms.txt sunny
```

**Warning**: Files related with analysis synchronization cannot specify a node because the files are managed by clusters.  And index close and open 
does not supported because of several problems. So, to complete analysis files synchronization process, you perform index close, open in kibana or using curl 


<h3>Restart remote node</h3>
If you modify a node configurations and install plugins and synchronize files, in order to apply these changes, elasticsearch engine must be restarted.
<br /><br />

* restart cluster

```shell script
$ escue cluster restart sunny
```

* restart specific node

```shell script
$ escue node restart -c sunny node-1
```

 
<h3>Install a plugin across nodes</h3>
Plugin install just supported from cluster command because of synchronization issue. And if already plugin installed, reinstall that plugin. Anyway, Because plugin 
is applied when elasticsearch restarted, reinstalled has no problem. But while reinstalling, If plugin install is failed, you must check plugin list.
<br /><br />

First, Check plugin list

```shell script
$ escue cluster list -p sunny
```

This command display installed plugin list per node like below in sunny cluster.

```shell script
node-1         node-2
analysis-icu   analysis-icu
analysis-nori  analysis-nori
```

Let's install plugins
<br />
* core type a plugin installation

```shell script
$ escue cluster install -p --ptype core -s analysis-nori sunny
```

* file type a plugin installation

```shell script
$ escue cluster install -p --ptype file -s path/to/plugin.zip sunny
```

* url type a plugin installation

```shell script
$ escue cluster install -p --ptype url -s https://some.domain/path/to/plugin.zip sunny
```

If installation is success, It will display below message

```shell script
node-1: Install analysis-nori is success.
node-2: Install analysis-nori is success.
```

<h3>Remove a plugin across nodes</h3>

```shell script
$ escue cluster remove -p -s analysis-nori sunny
```
<br />

<h3>Display transport logs</h3>
If command failed, display logs.

```shell script
$ escue logs
```

<br />

**For more terminal interface infomations, type**
```shell script
$ escue --help
```  

```shell script
$ escue [management command] --help
```  

* For cluster 
```shell script
$ escue cluster --help
```  


