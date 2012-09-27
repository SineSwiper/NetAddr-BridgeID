
use strict;
use warnings;

use 5.010001;

use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "Object for BridgeIDs (priority/MAC combos)",
  "AUTHOR" => "Brendan Byrd <BBYRD\@CPAN.org>",
  "BUILD_REQUIRES" => {
    "Test::CheckDeps" => "0.002",
    "Test::UseAllModules" => "0.10"
  },
  "CONFIGURE_REQUIRES" => {},
  "DISTNAME" => "NetAddr-BridgeId",
  "EXE_FILES" => [],
  "LICENSE" => "artistic_2",
  "NAME" => "NetAddr::BridgeId",
  "PREREQ_PM" => {
    "Moo" => "0.009001",
    "MooX::Types::MooseLike::Base" => "0.03",
    "MooX::Types::MooseLike::CLike" => 0,
    "NetAddr::MAC" => "0.7",
    "Scalar::Utils" => 0,
    "sanity" => "0.91"
  },
  "VERSION" => "0.90",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



