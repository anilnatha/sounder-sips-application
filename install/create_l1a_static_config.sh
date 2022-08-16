#!/bin/bash

script_dir=$(dirname $0)

src_dir=$1
dst_dir=$2
static_dir=$3

if [ -z "$src_dir" ]; then
    usage
fi

if [ -z "$dst_dir" ]; then
    usage
fi

if [ ! -e "$dst_dir" ]; then
    mkdir -p $dst_dir
fi

if [ -z "$static_dir" ]; then
    static_dir=$DEFAULT_STATIC_FILES_DIR
fi

# Copy SDPTK toolkit files
cp $script_dir/../ephemeris/leapsec.dat $dst_dir
cp $script_dir/../ephemeris/utcpole.dat $dst_dir

# Copy files from acceptance test directories, these are referenced by the input XML file
cp $src_dir/src/sips_pge/l1a_atms_snpp/acctest/in/pcf/SNDR.PGSToolkit_ProcessControlFile.pcf $dst_dir
cp $src_dir/src/sips_pge/l1a_atms_snpp/acctest/in/SNDR.SNPP.ATMS.L1A.sfif_201214135000.xml $dst_dir
cp $src_dir/src/sips_pge/l1a_atms_snpp/acctest/in/SNDR.SchemaParameterfile.060401120000.xsd $dst_dir

# Modify SFIF file to point to destination paths
sed -i 's|../../../static|'$dst_dir'|' $dst_dir/SNDR.SNPP.ATMS.L1A.sfif_201214135000.xml

# Modify to point leapsec.dat and utcpole.dat to our configuration static dir
sed -i -e 's|utcpole_20201220.dat|utcpole.dat|' \
       -e 's|../../in/pcf|'$dst_dir'|' \
       -e 's|~/database/common/TD|'$dst_dir'|' \
       $dst_dir/SNDR.PGSToolkit_ProcessControlFile.pcf

# Modify to point DEMs to a path controlled by Docker
sed -i -e 's|/peate/support/static/dem|'$static_dir'/dem|' \
       -e 's|/ref/devstable/STORE/mcf|'$static_dir'/mcf|' \
       $dst_dir/SNDR.PGSToolkit_ProcessControlFile.pcf

# Static files referenced in SFIF file
cp $src_dir/src/sips_pge/l1a_atms_snpp/static/SNDR.SNPP.ATMS.L1A.template.v02_02_08_201214135000.nc $dst_dir
cp $src_dir/src/sips_pge/l1a_atms_snpp/static/ATMS-SDR-CC_npp_20131201000000Z_20140101000000Z_ee00000000000000Z_PS-1-O-CCR-14-1487-JPSS-DPA-008-SIDEA-PE_noaa_all_all-_all.xml $dst_dir
cp $src_dir/src/sips_pge/l1a_atms_snpp/static/SNDR.SNPP.ATMS.L1A.calibration_data_200204184500.csv $dst_dir
cp $src_dir/src/sips_pge/l1a_atms_snpp/static/SNDR.SNPP.ATMS.APID_531_ENGHSKP_v11_200204184500.xml $dst_dir
cp $src_dir/src/sips_pge/l1a_atms_snpp/static/SNDR.SNPP.ATMS.L1A.apf_180412120000.xml $dst_dir
cp $src_dir/src/sips_pge/l1a_atms_snpp/static/SNDR.SIPS.SNPP.ATMS.L1A.SPDCMetConstants_170905120000.pev $dst_dir
cp $src_dir/src/sips_pge/l1a_atms_snpp/static/SNDR.SIPS.ATMS.L1A.SPDCMetStructure_161130151628.xml $dst_dir
cp $src_dir/src/sips_pge/l1a_atms_snpp/static/SNDR.SIPS.SNPP.ATMS.L1A.SPDCMetMappings_170905120000.xml $dst_dir

# Template PGE configuration file to be modified by the Jupyter notebook
cp $src_dir/src/sips_pge/l1a_atms_snpp/acctest/spdc_nominal2/in/SNDR.SNPP.ATMS.L1A.nominal2.config_201214135000.xml $dst_dir/pge_config_template.xml
