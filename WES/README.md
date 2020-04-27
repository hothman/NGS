

# README

Download and install [miniconda](https://docs.conda.io/en/latest/miniconda.html) or [anaconda](https://www.anaconda.com/products/individual)

## creating a new conda environment 

We use conda to install all the dependencies for the workflow. This would ease the task of installing software and tools on your local machine that are needed by the workflow. 

```
# creating a new envirement called covid19IPT_wf
conda create --name covid19IPT_wf
```

Once it is created we have to activate it in the current shell. 

```
conda activate covid19IPT_wf
```

Now we can start adding dependencies to the current environment. Let's start by adding the channels from bioconda.   

```
conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge
```
## Installing dependencies 

```
conda install -c bioconda vcftools bcftools 
```

## Download reference genome 

A bash script `./tools/download_GRCh37.sh` is available that allows you to automatically download the reference from Ensembl. You need only to modify the line`DESTINAION=/Destination/folder`  to point to a different directory on your machine. 

example 

```
# create a directory in your home 
$ mkdir ~/ref_genome
```

Then change the line ``DESTINAION=/Destination/folder`` to ``DESTINAION=~/ref_genome`` in the `download_GRCh37.sh` 



## Installing Nextflow 

In order to run the workflow you need to install Nextflow. First make sure you have java.

```
$ java -version  
```

If you get something like this then java is installed. 

```
openjdk version "11.0.7" 2020-04-14
OpenJDK Runtime Environment (build 11.0.7+10-post-Ubuntu-2ubuntu218.04)
OpenJDK 64-Bit Server VM (build 11.0.7+10-post-Ubuntu-2ubuntu218.04, mixed mode, sharing)
```

Then install Nextflow 

```
curl -s https://get.nextflow.io | bash
```

You can then run the hello world workflow to test the installation

```
./nextflow run hello
```

If the installation works well you would get something like the following

```
Hola world!
Bonjour world!
Ciao world!

Completed at: 27-Apr-2020 22:09:42
Duration    : 478ms
CPU hours   : (a few seconds)
Succeeded   : 4
```

A tutorial s available to introduce you to Nextflow at this link https://github.com/shaze/nextflow-course



## VCF files

Some dummy VCF files were generated for nine genes including ACE2. These are only intended for testing purpose. 

```
$ ls ./data/VCF
ACE2_dummy.vcf  CD209_dummy.vcf  CLEC4M_dummy.vcf  CTSB_dummy.vcf  CTSL_dummy.vcf  DPYD_dummy.vcf  G6PD_dummy.vcf  NQO2_dummy.vcf  XPA_dummy.vcf
```



