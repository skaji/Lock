use strict;
use warnings;
use utf8;
use Test::More;
use Lock;
use File::Temp qw(tmpnam);
use Sys::SigAction qw(timeout_call);
plan skip_all => "Does not support WIN" if $^O =~ /^win/i;

my $PID = $$;
my @remove;
sub tempfile {
    my $name = tmpnam;
    push @remove, $name;
    $name;
}
END { if ($$ == $PID) { unlink $_ for @remove } }

subtest shared_shared => sub {
    my $tempfile = tempfile;
    my $lock = Lock->new($tempfile);
    my $guard = $lock->shared;
    my $pid = fork;
    die unless defined $pid;
    if ($pid == 0) {
        my $timeout = timeout_call 0.1, sub { $lock->shared };
        if ($timeout) {
            exit 1;
        } else {
            exit 0;
        }
    }
    waitpid $pid, 0;
    is $?, 0;
};
subtest shared_exclusive => sub {
    my $tempfile = tempfile;
    my $lock = Lock->new($tempfile);
    my $guard = $lock->shared;
    my $pid = fork;
    die unless defined $pid;
    if ($pid == 0) {
        my $timeout = timeout_call 0.1, sub { $lock->exclusive };
        if ($timeout) {
            exit 0;
        } else {
            exit 1;
        }
    }
    waitpid $pid, 0;
    is $?, 0;
};
subtest exclusive_shared => sub {
    my $tempfile = tempfile;
    my $lock = Lock->new($tempfile);
    my $guard = $lock->exclusive;
    my $pid = fork;
    die unless defined $pid;
    if ($pid == 0) {
        my $timeout = timeout_call 0.1, sub { $lock->shared };
        if ($timeout) {
            exit 0;
        } else {
            exit 1;
        }
    }
    waitpid $pid, 0;
    is $?, 0;
};
subtest exclusive_exclusive => sub {
    my $tempfile = tempfile;
    my $lock = Lock->new($tempfile);
    my $guard = $lock->exclusive;
    my $pid = fork;
    die unless defined $pid;
    if ($pid == 0) {
        my $timeout = timeout_call 0.1, sub { $lock->exclusive };
        if ($timeout) {
            exit 0;
        } else {
            exit 1;
        }
    }
    waitpid $pid, 0;
    is $?, 0;
};

done_testing;
