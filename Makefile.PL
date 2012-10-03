use inc::Module::Install;

name     'Lingua-JA-TFWebIDF';
all_from 'lib/Lingua/JA/TFWebIDF.pm';

requires 'parent';
requires 'Carp';
requires 'Text::MeCab' => 0.20013;
requires 'Lingua::JA::WebIDF' => 0.40;
requires 'Lingua::JA::Halfwidth::Katakana';

test_requires 'Test::More' => 0.98;
test_requires 'Test::Fatal';
test_requires 'Test::Warn' => 0.20;
test_requires 'Test::Requires';

tests 't/*.t';
author_tests 'xt';

readme_from 'lib/Lingua/JA/TFWebIDF.pm';

resources(
    license    => 'http://dev.perl.org/licenses',
    repository => 'https://github.com/pawa-/Lingua-JA-TFWebIDF',
    bugtracker => 'https://github.com/pawa-/Lingua-JA-TFWebIDF/issues',
);

WriteAll;
