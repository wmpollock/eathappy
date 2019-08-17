#!/usr/bin/perl

#use CGI qw(:all);
use CGI::Pretty qw(:all);
use CGI::Carp qw(fatalsToBrowser);
use constant BASE_DIR => "$ENV{DOCUMENT_ROOT}/eathappy/data/gramma/images";
use constant SRC_DIR => join('/', BASE_DIR, "jpegs");
use constant STASH_DIR => join("/", BASE_DIR, "jpegs/done");



#open STDOUT, '|tee /var/tmp/,gagad';

if (param('shitcan')) {
    my $src_img = join('/', SRC_DIR, param('shitcan'));
    my $dst_img = join('/', STASH_DIR, param('shitcan'));
    rename($src_img, $dst_img) or 
        die "FATAL: couldn't move $src_img to $dst_img -- $!";
}

if (param('list') || param('shitcan')) {
    navigator();
} elsif (param('show') or param('show_clockwise') or param('show_counterclockwise')) {
    viewer();
} elsif (param('clockwise')) {
    clockwise();
} elsif (param('counterclockwise')) {
    counterclockwise();
} else {
  print header(), start_html();
  print "Please select an image from the navigator";
  print end_html(); 
}




sub viewer {
    print(header(),
	  start_html(-title => 'Image Viewer',
		     -style => [
				{-src => '/eathappy/Templates/css/visualizer.css'}
				],
		     -script => [
				 {-src => 'https://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js'},
				 {-src => '/eathappy/Templates/js/jQueryRotate.js'},
				 {-src => '/eathappy/Templates/js/visualizer.js#a'},
				 {-src => '/eathappy/Templates/js/zoom-master/jquery.zoom.min.js'},
				],
		     -class => 'imageViewer',
		    )
	 );
    
    my ($img, $rotate_link);
    my @links;

    my ($image_type) = grep(param($_), qw(show show_clockwise show_counterclockwise));

    my $img_src = param($image_type) or die "FATAL: no image source"; 

    (my $img_show_type = $image_type) =~ s/show_//;

    if (param('show')) {
	($img = join('/', SRC_DIR, param('show'))) =~ s-$ENV{DOCUMENT_ROOT}--;

        push(@links, a({-href => '#',
			-data_rotate => '90',
			-class => 'rotate right'},
                       'Rotate Right'));
        push(@links, a({-href => '#',
			-data_rotate => '-90',
			-class => 'rotate left',
		       },
                       'Rotate Left'));


    } else {
        $img = sprintf("$ENV{SCRIPT_NAME}?%s=%s", $img_show_type, $img_src);
        push(@links, a({-href => sprintf("$ENV{SCRIPT_NAME}?show=%s", $img_src)},
                       'Standard'));
    }

    if ($img_src =~ /scan(\d+)/) {
        my $cur_no = $1;
        push(@links, a({-href => sprintf("%s?%s=scan%4.4d.jpg", $ENV{SCRIPT_NAME}, $image_type, $cur_no + 1)},
                       'Next'));
        push(@links, a({-href => sprintf("%s?%s=scan%4.4d.jpg", $ENV{SCRIPT_NAME}, $image_type, $cur_no - 1)},
                       'Prev'));
    }


    my $nav = div({-class => 'navigation'},
		  join(" &bull; ", @links),
		 );



    print(
          p({-class => 'imagePath'}, param('show')),
          $nav,
	  div({-class => 'imageContainer'},
	      img({-src => $img,
		   -id => 'sourceImage',
		  }))
	  ,
          $nav,
          end_html()
          );

}

sub navigator {
    print header(), 
      start_html(-style => 	{-src => '/eathappy/Templates/css/visualizer.css'}),
	h1("Nav.");
    opendir DIR, SRC_DIR or 
      die "FATAL; Can't open ", SRC_DIR, " -- $!";

    my @list;

    foreach (sort readdir DIR) {
        (my $name = $_) =~ s/\.jpg$//i or next;

	push(@list, li(
		       a({-href => "$ENV{SCRIPT_NAME}?show=$_", -target => 'visualizer'}, $name), "\n", 
		       a({-href=> "$ENV{SCRIPT_NAME}?shitcan=$_", -class => 'delete'}, "&#x267b;")

		       )
	     )
		   }
    print ul({-class => 'imageList'}, @list);
    my $pages = ($#list + 1 )/ 2;
    print p(sprintf(div("%2.2d pages left:") . div("%d-%d items."),
		    $pages,
		    $pages * 4,
		    $pages * 5
		    )
	    );
    print end_html();
}

