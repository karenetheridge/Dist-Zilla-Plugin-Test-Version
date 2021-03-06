use strict;
use warnings;
use Test::More;
use Test::DZil;
use Test::Script 1.12;
use Test::NoTabs ();
use Test::EOL    ();
use File::chdir;
use Path::Class qw( file dir );

my $tzil = Builder->from_config(
  {
    dist_root    => 'corpus/a',
  },
  {
    add_files => {
      'source/dist.ini' => simple_ini(
        {},
        ['GatherDir'],
        ['FileFinder::ByName / MyFinder' => {
          dir => 'lib/X1',
        }],
        ['Test::Version' => {
          finder => 'MyFinder',
        }]
      ),
      'source/lib/X1/Foo.pm' => "package X1::Foo;\nour \$VERSION = 1.00;\n1;\n",
      'source/lib/X2/Bar.pm' => "package X2::Bar;\n1;\n",
    }
  },
);

$tzil->build;

is $tzil->prereqs->as_string_hash->{develop}->{requires}->{'Test::Version'}, '1', 'needs Test::Version 1';

my $fn = dir($tzil->tempdir)
  ->subdir('build')
  ->subdir('xt')
  ->subdir('author')
  ->file('test-version.t')
  ;

ok ( -e $fn, 'test file exists');

note $fn->slurp;

do {
  local $CWD = dir($tzil->tempdir)->subdir('build')->stringify;
  #note "CWD = $CWD";
  Test::NoTabs::notabs_ok      ( file(qw( xt author test-version.t ))->stringify, 'test has no tabs');
  Test::EOL::eol_unix_ok       ( file(qw( xt author test-version.t ))->stringify, 'test has good EOL',   { trailing_whitespace => 1 });
  script_compiles( file(qw( xt author test-version.t ))->stringify, 'check test compiles' );
  script_runs    ( file(qw( xt author test-version.t ))->stringify, 'check test runs'     );
};

done_testing;
