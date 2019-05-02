#!/usr/bin/perl -w

# Authors: Zhao Lin ( Email: joylin1993@163.com ) & Du Pengcheng.
# Date:2019/5/2.
# Script to draw linear comparison figures (SVG) of genomic CDS. 

use SVG;
if (@ARGV!=7) {
	print "perl $0 <line_seq> <rec> <seqline> <ident_max> <ident_min> <scale> <svg_file>\n";
	exit;
}
my ($line,$rec,$seqlen,$ident_max,$ident_min,,$scale,$svg_file)=@ARGV;
my %color=("+"=>"red","-"=>"green");
my $svg = SVG->new(width=>2500, height=>1500);

#input CDS file path
my @cds_lists=("D:/test/refseq_CDS","D:/test/queryseq_CDS");


##################################
##Draw seq  maps #################
##################################
open(LINE,$line) || die "OpenError: $line\n";
$i =0;
while (<LINE>) {
	chomp;
    my ($x0,$y0,$start,$end)=split /\t/, $_;
	$pep=$cds_lists[$i];
	$svg->line(x1 =>$x0, y1 =>$y0, x2 =>$x0+($end-$start+1)/$scale, y2 =>$y0, stroke=>'black',"stroke-width"=>2);
    open (PEP,$pep) || die "OpenError: $pep\n";
    while (<PEP>) {
	    chomp;
	    my ($gene,$gene_start,$gene_end,$direction)=split /\t/, $_;
	    ($gene_start,$gene_end)=sort {$a<=>$b} ($gene_start,$gene_end);
		    drawXTriangleLine($x0+($gene_start-$start)/$scale,$x0+($gene_end-$start)/$scale,$y0,10,$direction,$color{$direction});
			    if( $i == 0 ){
				   	my $x=$x0+($gene_start-$start)/$scale;
			    	my $y=$y0-9;
			    	my $x_mid=$x+($gene_end-$gene_start)/2/$scale;
			    	$svg->text(x =>$x_mid, y =>$y,"font-family"=>"Arial", "text-anchor"=>"start","font-size"=>10, "-cdata" => "$gene",transform => "rotate(-45 $x_mid,$y)");
					}else{
					my $x=$x0+($gene_start-$start)/$scale;
			    	my $y=$y0+15;
			    	my $x_mid=$x+($gene_end-$gene_start)/2/$scale;
			    	$svg->text(x =>$x_mid, y =>$y,"font-family"=>"Arial", "text-anchor"=>"start","font-size"=>10, "-cdata" => "$gene",transform => "rotate(45 $x_mid,$y)");
					}
        } 
        close PEP;
    $i+=1;
    }
close LINE; 
##input line text
$svg->text(x => 190, y =>200,"font-family"=>"Arial", "text-anchor"=>"end","font-size"=>14, "-cdata" =>"refseq");
$svg->text(x => 190, y =>300,"font-family"=>"Arial", "text-anchor"=>"end","font-size"=>14, "-cdata" =>"queryseq");


#####sequence aln
my $ident_diff=$ident_max-$ident_min;
my $colnum;
open(REC,$rec) || die "OpenError: $rec\n";
while (<REC>) {
    chomp;
    my ($ident,$c1,$c2,$c3,$c4,$d1,$d2,$d3,$d4)=split /\t/, $_;
    my $colnum=200-($ident-$ident_min)*100/$ident_diff;
    my $xv = [$c1,$c2,$c3,$c4];
    my $yv = [$d1,$d2,$d3,$d4];
    my $points = $svg->get_path(x => $xv, y => $yv, -type =>'polygon');
	$svg->polygon( %$points,'fill' =>"rgb($colnum,$colnum,$colnum)",'stroke' =>'grey','stoke-width' =>0.01 );
}
close REC; 

##################################
##Set the gradient bar############
##################################
my $style;
my $gradient;
my $grad02 = $svg->gradient(-type=>'linear',id=>"grey",
				x1=>"0%",
				y1=>"0%",
				x2=>"0%",
				y2=>"100%",
				spreadMethod=>"pad",
				gradientUnits=>"objectBoundingBox"	);
$grad02->stop(offset=>"0%",style=>{'stop-color'=>'rgb(100,100,100)','stop-opacity'=>"1"});
$grad02->stop(offset=>"100%",style=>{'stop-color'=>'rgb(200,200,200)','stop-opacity'=>"1"});
$svg->rect(x => 200, y => 400, width => 20, height => 100, fill => 'url(#grey)');
$svg->text(x => 230, y => 410,"font-family"=>"Arial", "text-anchor"=>"start","font-size"=>15, "-cdata" =>"$ident_max%");
$svg->text(x => 230, y => 500,"font-family"=>"Arial", "text-anchor"=>"start","font-size"=>15, "-cdata" =>"$ident_min%");



##################################
##Set the scale bar###############                              
##################################
$svg->line(x1 => 200, y1 => 100, x2 => 200+$seqlen/$scale, y2 => 100, stroke=>'black',"stroke-width"=>1.2);
$kvalue = 0;    
$ktext = 0;   
while( $kvalue < $seqlen ){
    $kspace=200+$kvalue/$scale;
    $svg->line(x1 => $kspace, y1 => 100, x2 => $kspace, y2 => 95, stroke=>'black',"stroke-width"=>1.2);
    $ktext= join("",$ktext,"K");
	$svg->text(x =>$kspace, y =>115,"font-family"=>"Arial", "text-anchor"=>"middle","font-size"=>10, "-cdata" => $ktext );
    $kvalue = $kvalue+1000;  
    $ktext = $kvalue/1000;   
    if ($kvalue>=$seqlen){
        $kspace=200+$seqlen/$scale;
        $svg->line(x1 => $kspace, y1 => 100, x2 => $kspace, y2 => 95, stroke=>'black',"stroke-width"=>1.2); 
    }
}


###output SVG file
my $out = $svg->xmlify;
open SVGFILE, ">$svg_file";
print SVGFILE $out;
print "OK";
1;


##################################################
#function: define the shape of CDS               #                      
##################################################
sub  drawXTriangleLine{
	my ($x_start,$x_end,$y,$line_width,$direction,$color)=@_;
	my $arrow_length;
	$y-=0.5*$line_width;
	if ($x_end-$x_start > 0.75*1.732*$line_width and $direction eq "+") {
		$arrow_length=0.75*1.732*$line_width;
		my $rect_x1=$x_start;                  my $rect_y1=$y;
		my $rect_x2=$x_end-$arrow_length;      my $rect_y2=$y;
		my $rect_x3=$x_end-$arrow_length;      my $rect_y3=$y+$line_width;
		my $rect_x4=$x_start;                  my $rect_y4=$y+$line_width;

		my $triangle_x1=$x_end-$arrow_length;  my $triangle_y1=$y-$line_width/4;
		my $triangle_x2=$x_end;                my $triangle_y2=$y+$line_width/2;
		my $triangle_x3=$x_end-$arrow_length;  my $triangle_y3=$y+1.25*$line_width;

		my $xv = [$rect_x1,$rect_x2,$triangle_x1,$triangle_x2,$triangle_x3,$rect_x3,$rect_x4];
		my $yv = [$rect_y1,$rect_y2,$triangle_y1,$triangle_y2,$triangle_y3,$rect_y3,$rect_y4];
		my $points = $svg->get_path(x => $xv, y => $yv, -type =>'polygon');
		$svg->polygon(%$points,'fill' =>'SteelBlue');
	}
	elsif ($x_end-$x_start <= 0.75*1.732*$line_width and $direction eq "+") {
		$arrow_length=$x_end-$x_start+1;
		my $triangle_x1=$x_start;  my $triangle_y1=$y-$line_width/4;
		my $triangle_x2=$x_end;    my $triangle_y2=$y+$line_width/2;
		my $triangle_x3=$x_start;  my $triangle_y3=$y+1.25*$line_width;
		
        my $xv = [$triangle_x1,$triangle_x2,$triangle_x3];
		my $yv = [$triangle_y1,$triangle_y2,$triangle_y3];
		my $points = $svg->get_path(x => $xv, y => $yv, -type =>'polygon');
		$svg->polygon( %$points, 'fill' =>'SteelBlue');
	}
	elsif ($x_end-$x_start > 0.75*1.732*$line_width and $direction eq "-") {
		$arrow_length=0.75*1.732*$line_width;
        my $rect_x1=$x_end;                      my $rect_y1=$y;
		my $rect_x2=$x_start+$arrow_length;      my $rect_y2=$y;
		my $rect_x3=$x_start+$arrow_length;      my $rect_y3=$y+$line_width;
		my $rect_x4=$x_end;                      my $rect_y4=$y+$line_width;
		
        my $triangle_x1=$x_start+$arrow_length;  my $triangle_y1=$y-$line_width/4;
		my $triangle_x2=$x_start;                my $triangle_y2=$y+$line_width/2;
		my $triangle_x3=$x_start+$arrow_length;  my $triangle_y3=$y+1.25*$line_width;

		my $xv = [$rect_x1,$rect_x2,$triangle_x1,$triangle_x2,$triangle_x3,$rect_x3,$rect_x4];
		my $yv = [$rect_y1,$rect_y2,$triangle_y1,$triangle_y2,$triangle_y3,$rect_y3,$rect_y4];
		my $points = $svg->get_path(x => $xv, y => $yv, -type =>'polygon');
		$svg->polygon( %$points, 'fill' =>'SteelBlue');
	}
	elsif ($x_end-$x_start <= 0.75*1.732*$line_width and $direction eq "-") {
		$arrow_length=$x_end-$x_start+1;
		my $triangle_x1=$x_end;      my $triangle_y1=$y-$line_width/4;
		my $triangle_x2=$x_start;    my $triangle_y2=$y+$line_width/2;
		my $triangle_x3=$x_end;      my $triangle_y3=$y+1.25*$line_width;
		
        my $xv = [$triangle_x1,$triangle_x2,$triangle_x3];
		my $yv = [$triangle_y1,$triangle_y2,$triangle_y3];
		my $points = $svg->get_path(x => $xv, y => $yv, -type =>'polygon');
		$svg->polygon( %$points, 'fill' =>'SteelBlue');
	}
}
