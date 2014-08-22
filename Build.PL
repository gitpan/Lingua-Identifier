use 5.014000;

use strict;
use warnings FATAL => 'all';
use lib 'inc';
use MyBuilder;



my %d = (
         module_name         => 'Lingua::Identifier',
         license             => 'Artistic_2_0',
         dist_author         => q{Alberto Simões <ambs@cpan.org>},
         dist_version_from   => 'lib/Lingua/Identifier.pm',
         share_dir           => 'share',
         configure_requires  =>
         {
          'Module::Build'    => '0.36',
         },
         build_requires      =>
         {
          'autodie'          => 0,
          'Test::More'       => 0,
          'Math::Matrix::MaybeGSL' => '0.005',
          'File::ShareDir'   => '1.03',
         },
         requires            =>
         {
          'Math::Matrix::MaybeGSL' => '0.004',
          'File::ShareDir'   => '1.03',
          'Text::Ngram'      => '0',
         },
         add_to_cleanup      => [ 'Lingua-Identifier-*' ],
);

my $builder = MyBuilder->new( %d );

$builder->create_build_script();
