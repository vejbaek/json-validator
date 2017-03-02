use Mojo::Base -strict;
use Mojo::JSON qw(encode_json decode_json );
use Mojo::Util 'dumper';
use Test::More;
use JSON::Validator;

plan skip_all => 'cpanm Test::JSON::Schema::Acceptance'
  unless eval 'use Test::JSON::Schema::Acceptance; 1';

my $opts = {
  only_test  => $ENV{ACCEPTANCE_TEST},
  skip_tests => [
    'Unicode code point',    # Valid unicode won't pass Mojo::JSON
    'dependencies',          # TODO
    'ref',                   # No way to fetch http://localhost:1234/...
  ],
};

my @drafts = qw( 4 );        # ( 3 4 )

for my $draft (@drafts) {
  my $accepter = Test::JSON::Schema::Acceptance->new($draft);

  $accepter->acceptance(
    sub {
      my $schema = decode_json(encode_json(shift));
      my $input  = decode_json(shift);
      my @errors = JSON::Validator->new->load_and_validate_schema($schema)->validate($input);
      note(dumper([$input, $schema, @errors])) if $ENV{ACCEPTANCE_TEST};
      return @errors ? 0 : 1;
    },
    $opts,
  );
}

done_testing();
