<h1 align="center">ElasticSearch resCUE(ESCUE)</h1>

<p align="center">Elasticsearch terminal interface manager</p>

<h2>Description</h2>
Elasticsearch is a big data distributed search system. It supports very diverse search functions and shows fast search 
speed using inverted index. However, Managing elasticsearch cluster has some annoying works which are installation on each sever
or neccessary files syncronization or to restart es etc... . So, ESCUE is motivated from that works and supports some functions
that can solve this annoying and uncomportable works at the toy levels.
<br />
<br />
ESCUE is linux terminal interface application and in order to manage distributed system across multiple servers, ESCUE requires 
the identity file containing ssh private key in almost any tasks. So I recommend you before using, that register ssh public 
key on multiple severs where node will be installed first. Otherwise, in almost tasks, identity file option must be speicified.
If you discover yourself typing -i ......... in the terminal, you might give up using ESCUE.


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
you consider typing 'rm -rf escue'.. never fucking me...


<h2>Installation</h2>
First, git clone
```shell script
$git clone <url>
```
Second, move escue
```shell script
$cd escue
$bash config/install.sh
```

<h2>Uses</h2>
Assuming that the ssh public key has been registered on remote severs where nodes will be installed.<br />
If you don't know what to do, see [this blog post](https://mohitgoyal.co/2021/01/12/basics-of-ssh-generate-ssh-key-pairs-and-establish-ssh-connections-part-1) <br /><br />
First you must create cluster.
 ```shell script
$escue cluster create sunny
```
if success, sunny cluster will be created.
Check clusters

```shell script
$escue cluster list
```
Next, create node, and typing the elasticsearch configuration and server information to connect remote sever.

```shell script
$escue node create -c sunny node-1
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

<h3>Install plugin across nodes</h3>
Plugin install just supported from cluster command because of synchronization issue. And if already plugin installed, reinstall that plugin.
Anyway, Because plugin is applied when elasticsearch restarted, reinstalled has no problem. But while reinstalling, 
If plugin install is failed, you must check plugin list.

First, Check plugin list

```shell script
$ escue cluster -p list sunny
```
This command display installed plugin list per node in sunny

```shell script
node-1         node-2
analysis-icu   analysis-icu
analysis-nori  analysis-nori
```

Let's install plugins

