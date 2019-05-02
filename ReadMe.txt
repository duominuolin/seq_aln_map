##./bin/draw_seq_maps.pl
Description:
draw linear comparison figures (SVG) of genomic CDS

Authors:
Zhao Lin ( Email: joylin1993@163.com ) & Du Pengcheng
Date:2019/5/2

requirements:SVG-2.78

Usage:
	perl draw_seq_maps.pl <line_seq> <rec> <seqline> <ident_max> <ident_min> <scale> <svg_file>
optional arguments:
	<line_seq>           position , start and end of sequence (x,y,seq_start seq_end)
	<rec>                idnetity and positon of blast hits on <scale> (ident,ref_start,ref_end,query_start,query_end,y1,y1,y2,y2)
	<seqline>            ref seq length 
    <ident_max>          max identity values of multi hits or set by user 
	<ident_min>          min identity values of multi hits or set by user 
	<scale>              Zoom out scale
	<svg_file>           out SVG file

#input CDS file in script:
CDS file format(Tab split)
gene gene_start gene_end direction

example:
perl draw_seq_maps.pl line.txt rec.txt 16160 100 90 20 test.svg


##./test/
test data of draw_seq_maps.pl

##./packages/
SVG-2.78.tar.gz
