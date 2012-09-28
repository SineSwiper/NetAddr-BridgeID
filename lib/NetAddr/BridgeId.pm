package NetAddr::BridgeID;

# ABSTRACT: Object for BridgeIDs (priority/MAC combos)
# VERSION

use sanity;
use NetAddr::MAC;
use Scalar::Util qw/blessed/;
use Params::Util qw/_INSTANCEDOES/;

use Moo;
use MooX::Types::MooseLike::Base qw/Str/;
use MooX::Types::CLike qw/UShort/;

has original => (
   is       => 'ro',
   isa      => Str,
   required => 1,
);
has priority => (
   is       => 'ro',
   isa      => UShort,
   required => 1,
);
has mac_obj => (
   is       => 'ro',
   isa      => sub {
      die "Not a NetAddr::MAC object!" unless ( _INSTANCEDOES $_[0], 'NetAddr::MAC' );
   },
   required => 1,
   handles  => {
      (map { $_ => $_ } qw(
         is_eui48
         is_eui64
         is_multicast
         is_unicast
         is_local
         is_universal
         as_basic
         as_bpr
         as_cisco
         as_ieee
         as_ipv6_suffix
         as_microsoft
         as_singledash
         as_sun
         as_tokenring
         to_eui48
         to_eui64
      )),
      qw(
         mac  original
      ),
   },
);

sub bridge_id { $_[0]->priority.'#'.$_[0]->as_cisco; }

around BUILDARGS => sub {
   my ($orig, $self) = (shift, shift);
   my %opts;

   if (@_ == 1) {
      my $arg = pop;
      if (blessed $arg) {
         if    ($arg->isa('NetAddr::BridgeID')) { $opts{bridge_id} = $arg->original; }
         elsif ($arg->isa('NetAddr::MAC'))      { $opts{mac_obj}   = $arg; }
         else                                   { $opts{bridge_id} = $arg; }
      }
      elsif (ref $arg eq 'ARRAY') { %opts = @$arg; }
      elsif (ref $arg eq 'HASH')  { %opts = %$arg; }
      else                        { $opts{bridge_id} = $arg; }
   }
   else { %opts = @_; }

   # parse vars from bridge_id
   if (defined $opts{bridge_id}) {
      $opts{bridge_id} =~ /^(\d+)\#(.+)$/;
      $opts{priority}  //= $1;
      $opts{mac}       //= $2;
   }

   # parse mac from mac_obj
   $opts{mac} //= $opts{mac_obj}->original if (defined $opts{mac_obj});

   # defaults
   $opts{priority}  //= 0;
   $opts{bridge_id} //= $opts{priority}.'#'.$opts{mac};
   #$opts{mac_obj}   //= NetAddr::MAC->new( mac => $opts{mac} );
   
   # NetAddr::MAC has some weird issues with MAC translation here
   # (see https://rt.cpan.org/Ticket/Display.html?id=79915)
   unless ($opts{mac_obj}) {
      my $new_mac = $opts{mac};
      $new_mac =~ s/[^\da-f]//gi;
      $new_mac =~ s/(.{4})(?=.)/$1./g;
      $opts{mac_obj} = NetAddr::MAC->new( mac => $new_mac );
      $opts{mac_obj}->{original} = $opts{mac};  # Ugly and hacky; remove when bug is fixed
   }
   
   # bridge_id is actually 'original'
   $opts{original} = delete $opts{bridge_id};
   delete $opts{mac};

   $orig->($self, \%opts);
};

1;
