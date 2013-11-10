MockBeaneater
==================

[![Build Status](https://travis-ci.org/seanxiesx/mock_beaneater.png)](https://travis-ci.org/seanxiesx/mock_beaneater)

Mock beaneater that goes AH-HEE-OH-HEE-AH-HEE\*. Intended for use in tests.

\*sound a beaneater makes

Usage
-----

Use a mock beaneater like you would a beaneater!

    >> require 'mock_beaneater'
    >> mbp = MockBeaneater::Pool.new
    >> mtube = mbp.tubes.find('my-tube')
    >> mtube.put('my-msg')
    => {:status=>"INSERTED", :body=>nil, :id=>1}
    >> mjob = mtube.reserve
    => #<MockBeaneater::Job id=1 body="msg">
    >> mjob.delete

TODO
-----

* stats
* ttr
* ...
