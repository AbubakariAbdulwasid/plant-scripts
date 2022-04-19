test:
	perl demo_test.t

test_travis:
	perl demo_test.t travis

clean:
	rm -f *rachypodium* && rm -f Compara*gz 
	rm -f new_genomes.txt && rm -f uniprot_report_EnsemblPlants.txt
	rm -f arabidopsis_thaliana*.tar.gz
	rm -f plants_species-tree*.nh
	rm -f oryza_sativa*

install:
	sudo apt-get install -y wget mysql-client libmysqlclient-dev bedtools pip cpanminus

install_REST:
	cpanm --local-lib lib --installdeps --notest --cpanfile lib/cpanfileREST .
	pip3 install --user requests

install_biomart_r:
	Rscript install_R_deps.R

install_ensembl:
	cpanm --local-lib lib --installdeps --notest --cpanfile lib/cpanfileEnsembl .
	cd lib && git clone https://github.com/Ensembl/ensembl.git
	cd lib && git clone https://github.com/Ensembl/ensembl-variation.git
	cd lib && git clone https://github.com/Ensembl/ensembl-funcgen.git
	cd lib && git clone https://github.com/Ensembl/ensembl-compara.git
	cd lib && git clone https://github.com/Ensembl/ensembl-metadata.git
	cd lib && git clone -b release-1-6-924 --depth 1 https://github.com/bioperl/bioperl-live.git

install_repeats:
	pip3 install --user -r lib/requirements.txt
	cd lib && git clone https://github.com/EnsemblGenomes/Red.git && cd Red/src_2.0 && make bin && make
	#in case you need to use an alternative g++ compiler
	#cd lib && git clone https://github.com/EnsemblGenomes/Red.git && cd Red/src_2.0 && make bin && make CXX=g++-10
	cd lib && git clone https://github.com/lh3/minimap2.git && cd minimap2 && make
	cd files && wget -c https://github.com/Ensembl/plant-scripts/releases/download/v0.3/nrTEplantsJune2020.fna.bz2 && bunzip2 nrTEplantsJune2020.fna.bz2

install_redat:
	cd files && wget -c ftp://ftpmips.helmholtz-muenchen.de/plants/REdat/mipsREdat_9.3p_ALL.fasta.gz && gunzip mipsREdat_9.3p_ALL.fasta.gz

test_repeats_travis:
	cd repeats && ./Red2Ensembl.py ../files/Arabidopsis_thaliana.fna.gz test_Atha_chr4 --msk_file Atha.sm.fna

test_repeats:
	cd repeats && ./Red2Ensembl.py ../files/Arabidopsis_thaliana.fna.gz test_Atha_chr4 --msk_file Atha.sm.fna && ./AnnotRedRepeats.py ../files/nrTEplantsJune2020.fna test_Atha_chr4 --bed_file test.nrTEplants.bed

uninstall_repeats:
	cd files && rm -rf nrTEplantsJune2020.fna*
	cd lib && rm -rf Red minimap2 

clean_repeats:
	cd repeats && rm -rf test_Atha_chr4 Atha.sm.fna test.nrTEplants.bed

install_pangenes:
	cd pangenes/bin && wget https://github.com/lh3/minimap2/releases/download/v2.17/minimap2-2.17.tar.bz2 && tar xfj minimap2-2.17.tar.bz2 && cd minimap2-2.17 && make && cd .. && rm -f minimap2-2.17.tar.bz2
	cd pangenes/bin && wget https://github.com/gpertea/gffread/releases/download/v0.12.7/gffread-0.12.7.Linux_x86_64.tar.gz && tar xfz gffread-0.12.7.Linux_x86_64.tar.gz && rm -f gffread-0.12.7.Linux_x86_64.tar.gz
	cd files && wget -c https://github.com/Ensembl/plant-scripts/releases/download/v0.4/test_rice.tgz && tar xfz test_rice.tgz && rm -f test_rice.tgz

# see https://github.com/ekg/wfmash for other options
install_wfmash:
	-sudo apt install cmake libjemalloc-dev zlib1g-dev libgsl-dev libhts-dev
	-cd pangenes/bin && git clone https://github.com/ekg/wfmash && cd wfmash && cmake -H. -Bbuild && cmake --build build -- -j 3

install_gsalign:
	-cd pangenes/bin && git clone https://github.com/hsinnan75/GSAlign.git && cd GSAlign && make

uninstall_pangenes:
	-cd pangenes/bin && rm -rf gffread-0.12.7.Linux_x86_64 minimap2-2.17 wfmash GSAlign
	cd files && rm -rf test_rice

test_pangenes:
	cd pangenes && perl get_pangenes.pl -d ../files/test_rice
