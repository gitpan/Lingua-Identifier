#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

use Lingua::Identifier;

my @files = <t/files/*.txt>;


plan tests => scalar(@files);


for my $f (@files) {
    $f =~ m!([^/]+)\.txt!;
    my $lang = $1;

    my $str = Lingua::Identifier::_load_file($f);
    my $id = Lingua::Identifier::_infer_language($str);
    is $id => $lang, "Testing $lang";
}
