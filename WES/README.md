# README

## creating a new conda envirement 
We use conda to install all the dependencies for the workflow

```
# creating a new envirement called wes_wf
conda create --name wes_wf
```

Once it is created we have to activate it in the current shell. 

```
conda activate wes_wf
```

Now we can start adding dependencies to the current envirement. Let's start by adding the channels from bioconda.   

```
conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge
```
## Installing dependecies 

```
conda install -c bioconda bowtie  samtools 
```










