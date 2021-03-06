#!/usr/bin/env bash

BIN=$(dirname "$0")

DATA_DIR=${BIN}/../data

mkdir -p ${DATA_DIR}

loci="A B C DRB1 DQB1 DPB1 DPA1 DQA1"
base_url="https://raw.githubusercontent.com/ANHIG/IMGTHLA"

RELEASES=`echo ${RELEASES} | sed s'/"//'g | sed s'/,/ /g'`

echo "ALIGN RELEASES = ${RELEASES}"

for dbversion in ${RELEASES};do
	for loc in ${loci};do
		dbversion_trimmed=`echo ${dbversion} | sed 's/\.//g'`
		msf_url=${base_url}/${dbversion_trimmed}"/msf/"${loc}"_gen.msf"
		mkdir -p ${DATA_DIR}/${dbversion_trimmed}
		curl -L ${msf_url} -o ${DATA_DIR}/${dbversion_trimmed}"/"${loc}"_gen.msf"
		perl ${BIN}/change_format.pl ${DATA_DIR}/${dbversion_trimmed}"/"${loc}"_gen.msf" ${DATA_DIR}/${dbversion_trimmed}"/"${loc}"_gen.sth"
		rm ${DATA_DIR}/${dbversion_trimmed}"/"${loc}"_gen.msf"

		msf_url=${base_url}/${dbversion_trimmed}"/msf/"${loc}"_nuc.msf"
		curl -L ${msf_url} -o ${DATA_DIR}/${dbversion_trimmed}"/"${loc}"_nuc.msf"
		perl ${BIN}/change_format.pl ${DATA_DIR}/${dbversion_trimmed}"/"${loc}"_nuc.msf" ${DATA_DIR}/${dbversion_trimmed}"/"${loc}"_nuc.sth"
		rm ${DATA_DIR}/${dbversion_trimmed}"/"${loc}"_nuc.msf"

		msf_url=${base_url}/${dbversion_trimmed}"/msf/"${loc}"_prot.msf"
		curl -L ${msf_url} -o ${DATA_DIR}/${dbversion_trimmed}"/"${loc}"_tmp.msf"
		perl ${BIN}/change_format.pl ${DATA_DIR}/${dbversion_trimmed}"/"${loc}"_tmp.msf" ${DATA_DIR}/${dbversion_trimmed}"/"${loc}"_tmp.sth"
		perl -ne 'END{foreach my $line (@data){if($line !~ /^\w+\d{0,1}\*/){print $line,"\n";}else{my($id,$s_seq) = split(/\s+/,$line);my $n = length($s_seq);if($n != $max){ my $add = "." x ($max - $n); $s_seq = $s_seq.$add;}print sprintf("%-".$space."s %".$max."s",$id,$s_seq),"\n";}}}chomp;push(@data,$_);next if($_ !~ /^\w+\d{0,1}\*/);my $n = length($_);my($id,$s_seq) = split(/\s+/,$_);$space = ($n - (length($id) + length($s_seq))) + length($id) -1;$max = length($s_seq) > $max ? length($s_seq) : $max;' ${DATA_DIR}/${dbversion_trimmed}"/"${loc}"_tmp.sth" > ${DATA_DIR}/${dbversion_trimmed}"/"${loc}"_prot.sth"
		rm ${DATA_DIR}/${dbversion_trimmed}/${loc}"_tmp.msf"
		rm ${DATA_DIR}/${dbversion_trimmed}/${loc}"_tmp.sth"

	done
done


if [ "$KIR" == "True" ]; then
	kirloci="'KIR3DS1 KIR3DP1 KIR3DL3 KIR3DL2 KIR3DL1 KIR2DS5 KIR2DS4 KIR2DS3 KIR2DS2 KIR2DS1 KIR2DP1 KIR2DL4"
	kirbase="ftp://ftp.ebi.ac.uk/pub/databases/ipd/kir/msf"
	for kirloc in ${kirloci};do
		kirurl=${kirbase}/${kirloc}"_gen.msf"
		curl -L ${kirurl} -o ${DATA_DIR}/${kirloc}"_gen.msf"
		perl ${BIN}/change_format.pl ${DATA_DIR}/${kirloc}"_gen.msf" ${DATA_DIR}/${kirloc}"_gen.sth"
		rm ${DATA_DIR}/${kirloc}"_gen.msf"
	done
fi

