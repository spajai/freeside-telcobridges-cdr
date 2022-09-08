package FS::cdr::telcobridges;

use strict;

use vars qw( @ISA %info);
use Date::Parse;

@ISA = qw(FS::cdr);

# 2020-03-01 00:55,END,Calling='111111111',Called='2222222222',NAP='NAP_SS7',Duration='7',TerminationCause='NORMAL_CALL_CLEARING',Direction='originate'

%info = (
    'name'          => 'Telcobridges',
    'weight'        => 120,
    'header'        => 0,
    'type'          => 'csv',
    'sep_char'      => ',',
    'import_fields' => [

        # TimeStamp
        sub {
            my ( $cdr, $raw_calldate ) = @_;
            # %m/%d/%y %H:%M:%S
            $raw_calldate =~ /(\d{2})\/(\d{2})\/(\d{4})\s(\d{2})\:(\d{2}):(\d{2})/;
            my $calldate = "$1/$2/$3 $4:$5:$6";
            $cdr->set( 'calldate', $calldate );
            my $tmp_date = str2time( $calldate );
            $cdr->set( 'startdate', $tmp_date );
        },    #DateTime
              #BEG/END
        sub {
            my ( $cdr, $event, $conf, $param ) = @_;
            if ( uc( $event ) ne 'END' ) {
                $param->{skiprow} = 1;
            }
        },

        #Calling
        sub {
            my ( $cdr, $source_caller, $conf, $param ) = @_;

            #Calling='12345556'
            my $src = _get_val( $source_caller );
            $cdr->set( 'src', $src );
        },

        #Called
        sub {
            my ( $cdr, $destination_caller, $conf, $param ) = @_;

            #Called='123456677'
            my $dst = _get_val( $destination_caller );
            $cdr->set( 'dst', $dst );
        },

        #NAP
        sub {
            my ( $cdr, $nap, $conf, $param ) = @_;

            #NAP='NAP_SS7'
            my $nap_val = _get_val( $nap );
            if ( $nap_val =~ /^(NAP_SIP_166|NAP_SIP_OSNET|NAP_SIPWISE_1)/g ) {
                $cdr->set( 'channel', $nap_val );
            } else {

                #NAP is not from above then skip
                $param->{skiprow} = 1;
            }
        },

        #Duration
        sub {
            my ( $cdr, $duration, $conf, $param ) = @_;

            #Duration='7'
            # $cdr->set('billsec', sprintf('%.0f', $seconds));
            my $seconds = sprintf( '%.0f', _get_val( $duration ) );
            if ( int( $seconds ) > 0 ) {
                $cdr->set( 'billsec',  $seconds );
                $cdr->set( 'duration', $seconds );
            } else {

                #skip if duration is 0
                $param->{skiprow} = 1;
            }
        },

        #TerminationCause
        sub {
            my ( $cdr, $description, $conf, $param ) = @_;

            # TerminationCause='NORMAL_CALL_CLEARING',Direction
            if ( $description =~ /TerminationCause/ig ) {
                my $desc = _get_val( $description );
                if ( $desc =~ /^(NORMAL_CALL_CLEARING|NORMAL|NORMAL_UNSPECIFIED)/ ) {
                    $cdr->set( 'description', $desc );
                } else {
                    $param->{skiprow} = 1;
                }
            } elsif ( $description =~ /Direction/ig ) {
                my $direction = _get_val( $description );
                $cdr->set( 'disposition', undef );
            }
        },

        #direction
        sub {
            my ( $cdr, $direction, $conf, $param ) = @_;

            # Direction
            if ( $direction =~ /Direction/ig ) {
                my $disposition = _get_val( $direction );
                $cdr->set( 'disposition', $disposition );
            } else {
                $cdr->set( 'disposition', undef );
            }
        },
    ],
);

sub skip {
    map { '' } ( 1 .. $_[0] );
}

sub _get_val {
    my $val = ( split( '=', $_[0] ) )[1];
    $val =~ s/(^\'|\'$)//gs;
    $val =~ s/\'//g;
    return $val;
}

sub _get_key_val {
    my @val = ( split( '=', $_[0] ) );
    $val[1] =~ s/^\'|\'$//gs;
    return @val;
}

1;

__END__

Author := spajai@cpan.org

Desc   :=  This is telecobridges specific cdr importer.
