# Settings
CONDA_ENV=community_tutorial
SHELL=shell
MINICONDA_URL=https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh

ifeq ($(OS),Windows_NT)
    $(info VAR is $(OS))
    $(info VAR is $(OS))
    SHELL:=cmd
    $(shell del *.o)
    CONDA := $(strip $(firstword $(shell where conda.exe)))
    $(info VAR is $(CONDA))
    BASE := $(strip $(firstword $(subst \Scripts\conda.exe,,$(CONDA))))
    $(info BASE is $(BASE))
    ACTIVATE=${BASE}\condabin\conda.bat
    $(info ACTIVATE is $(ACTIVATE))
#    ${CONDA} install -n base -c conda-forge mamba
else
    CONDA := $(strip $(shell which conda))
    BASE := $(shell dirname $(shell dirname ${CONDA}))
    ACTIVATE=${BASE}/bin/activate
endif

$(info ACTIVATE is $(ACTIVATE))
default: help

install-conda: ## install Miniconda
    ifeq ($(OS),Windows_NT)

		MINICONDA_URL=https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe
		powershell -Command "(New-Object System.Net.WebClient).DownloadFile('$(MINICONDA_URL)', 'miniconda.exe')"
		.\miniconda.exe /InstallationType=JustMe /RegisterPython=0 /S /D=%USERPROFILE%\Miniconda3
    else
    	MINICONDA_URL=https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
        curl -L $(MINICONDA_URL) -o miniconda.sh
        bash miniconda.sh -b
    endif
.PHONY: install-conda

create-env: ## create conda environment
	ifeq ($(OS),"Windows_NT")
		$(info SHELL is ${SHELL})
		$(info VAR is $(CONDA))
		${CONDA} install -n base -c conda-forge mamba
		if ${CONDA} info --envs | findstr "community_tutorial"; then \
		   mamba env update -n community_tutorial -f environment.yml; \
		else \
			${CONDA} install -n base -c conda-forge mamba && \
			C:\ProgramData\Anaconda3\Scripts\activate.bat base && \
			mamba env create -f environment.yml && \
			C:\ProgramData\Anaconda3\Scripts\activate.bat community_tutorial && Rscript -e 'devtools::install_github("SoloveyMaria/community", upgrade = "always"); q()'; \
		fi
	else
		if ${CONDA} env list | grep ${CONDA_ENV}; then \
		   mamba env update -n ${CONDA_ENV} -f environment.yml; \
		else \
			conda install -n base -c conda-forge mamba && \
			source activate base && \
			mamba env create -f environment.yml && \
			source activate ${CONDA_ENV} && Rscript -e 'devtools::install_github("SoloveyMaria/community", upgrade = "always"); q()'; \
		fi
	endif
.PHONY: create-env

download-data: ## download preprocessed data
	curl https://zenodo.org/record/7565938/files/anno_cells_corr.txt -o src/anno_cells_corr.txt;
	curl https://zenodo.org/record/7565938/files/anno_samples_corr.txt -o src/anno_samples_corr.txt;
	curl https://zenodo.org/record/7565938/files/counts_corr.csv.gz -o src/counts_corr.csv.gz
.PHONY: download-data

run-jupyter: ## run jupyter notebooks
	source ${ACTIVATE} ${CONDA_ENV} && \
        jupyter notebook

help:
#	#@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.PHONY: help
