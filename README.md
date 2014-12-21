# NAME

Lock - do something with file lock

# SYNOPSIS

    use Lock;

    my $lock = Lock->new(".lock");

    $lock->shared(sub {
        print "do something with shared lock\n";
    });

    $lock->exclusive(sub {
        print "do something with exclusive lock\n";
    });

# DESCRIPTION

Lock is ...

# LICENSE

Copyright (C) Shoichi Kaji.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Shoichi Kaji <skaji@cpan.org>
