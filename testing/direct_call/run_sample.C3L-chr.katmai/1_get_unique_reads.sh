# Run get_unique step on MantaDemo test data 
# Direct (not parallel) evaluation 

CONFIG="project_config.run_sample.C3L-chr.katmai.sh"

#NORMAL="/data/TestData/MantaDemo/HCC1954.NORMAL.30x.compare.COST16011_region.bam"
#TUMOR="/data/TestData/MantaDemo/G15512.HCC1954.1.COST16011_region.bam"

# From katmai.BamMap.dat
# C3L-00008.WGS.N.hg38	C3L-00008	UCEC	WGS	blood_normal	/diskmnt/Projects/cptac_downloads_3/GDC_import/data/846bf455-89b4-4840-b113-e529ffa13277/243bfb3c-d06b-4de5-a6c3-7fa7e2c5fb74_gdc_realn.bam	204714582211	BAM	hg38	846bf455-89b4-4840-b113-e529ffa13277	katmai
# C3L-00008.WGS.T.hg38	C3L-00008	UCEC	WGS	tumor	/diskmnt/Projects/cptac_downloads_3/GDC_import/data/1c0e0f84-4caf-4493-9b2f-8f5f9ef9231b/f6924a26-a14f-45a3-b4bd-7a4592d34065_gdc_realn.bam	200107040765	BAM	hg38	1c0e0f84-4caf-4493-9b2f-8f5f9ef9231b	katmai

# Assume /data3 maps to /diskmnt/Projects/cptac_downloads_3/GDC_import/data
NORMAL="/data3/846bf455-89b4-4840-b113-e529ffa13277/243bfb3c-d06b-4de5-a6c3-7fa7e2c5fb74_gdc_realn.bam"
TUMOR="/data3/1c0e0f84-4caf-4493-9b2f-8f5f9ef9231b/f6924a26-a14f-45a3-b4bd-7a4592d34065_gdc_realn.bam"

#   get_unique.sh [options] SAMPLE_NAME PROJECT_CONFIG BAM

bash /BICSEQ2/src/get_unique.sh $@ C3L-00008_tumor $CONFIG $TUMOR

>&2 echo Exiting after tumor
exit

bash /BICSEQ2/src/get_unique.sh $@ C3L-00008_blood_normal $CONFIG $NORMAL

