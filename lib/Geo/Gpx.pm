package Geo::Gpx;
use strict;
use XML::Simple;
use Geo::Cache;
use Time::CTime qw();

BEGIN {
	use vars qw ($VERSION);
	$VERSION     = 0.10;
}

# Docs {{{

=head1 NAME

Geo::Gpx - Create and parse Groundspeak/Geocaching GPX files.

=head1 SYNOPSIS

    # Should work now
    use Geo::Gpx;
    my $gpx = Geo::Gpx->new( @waypoints );
    my $xml = $gpx->xml;

    # Might work later
    my $gpx = Geo::Gpx->new( xml => $xml );
    my @waypoints = $gps->waypoints;

=head1 DESCRIPTION

The goal of this module is to produce GPX/XML files which are parseable
by both GPX Spinner and EasyGPS.

=head1 AUTHOR

	Rich Bowen
	rbowen@rcbowen.com

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut

# }}}

# sub new {{{

sub new {
    my $class = shift;
    my $self = {};

    if (ref $_[0] eq 'Geo::Cache') {
        # They're waypoints
        my @waypoints = @_;
        $self->{waypoints} = \@waypoints;

    } elsif ( $_[0] eq 'xml' ) {
        # Provided XML
        # I think this is probably hard
    } else {
        # Huh?
        warn "Invalid arguments.";
    }

    bless $self, $class;
    return $self;
} # }}}

# sub xml {{{

sub xml {
    my $self = shift;

    my $ret = q|<?xml version="1.0" encoding="utf-8"?>
<gpx xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="1.0" creator="Geo::Gpx" xsi:schemaLocation="http://www.topografix.com/GPX/1/0 http://www.topografix.com/GPX/1/0/gpx.xsd http://www.groundspeak.com/cache/1/0 http://www.groundspeak.com/cache/1/0/cache.xsd" xmlns="http://www.topografix.com/GPX/1/0">
<desc>GPX file generated by Geo::Gpx</desc>
<author>Groundspeak</author>
<email>contact@groundspeak.com</email>
|;

    my $t =
      Time::CTime::strftime( '%Y-%m-%dT%T.0000000-07:00', localtime );
    $ret .= "<time>$t</time>\n";

    $ret .= "<keywords>cache, geocache, groundspeak</keywords>\n";

    # Need a min, max on the lon and lat
    my $wpts   = '';
    my $minlon = 180;
    my $minlat = 90;
    my $maxlon = -180;
    my $maxlat = -90;

    foreach my $wpt ( @{ $self->{waypoints} } ) {
        $minlon = $wpt->lon if $wpt->lon < $minlon;
        $minlat = $wpt->lat if $wpt->lat < $minlat;

        $maxlat = $wpt->lat if $wpt->lat > $maxlat;
        $maxlon = $wpt->lon if $wpt->lon > $maxlon;

        $wpts .= $wpt->xml;
    }

    $ret .=
qq|<bounds minlat="$minlat" minlon="$minlon" maxlat="$maxlat" maxlon="$maxlon" />\n|;

    $ret .= $wpts;
    $ret .= "</gpx>\n";

    return $ret;

}    # }}}

sub gpx {
    my $self = shift;
    return $self->xml;
}

sub loc {
    my $self = shift;
    my $ret = q|<?xml version="1.0" encoding="ISO-8859-1"?>
<loc version="1.0" src="Groundspeak">
|;
    
    foreach my $wpt ( @{ $self->{waypoints} } ) {
        $ret .= $wpt->loc;
    }

    $ret .= q|</loc>|;
    return $ret;
}

sub gpsdrive {
    my $self = shift;
    my $ret = '';
    foreach my $wpt ( @{ $self->{waypoints} } ) {
        $ret .= $wpt->gpsdrive;
    }
    return $ret;
}

1;
