use inc::Module::Install;

name     'Lingua-JA-TFWebIDF';
all_from 'lib/Lingua/JA/TFWebIDF.pm';

requires 'parent';
requires 'Carp';
requires 'Lingua::JA::TFIDF' => 0.04;
requires 'Lingua::JA::WebIDF';
requires 'List::MoreUtils';

test_requires 'Test::More' => 0.88; # done_testing

tests 't/*.t';
author_tests 'xt';

readme_from 'lib/Lingua/JA/TFWebIDF.pm';

resources(
    license    => 'http://dev.perl.org/licenses',
    repository => 'https://github.com/pawa-/Lingua-JA-TFWebIDF',
    bugtracker => 'https://github.com/pawa-/Lingua-JA-TFWebIDF/issues',
);

WriteAll;
