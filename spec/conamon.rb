require 'rspec'
require 'conamon'

describe 'Conamon' do
  include Conamon

  describe 'thread_last' do
    context 'Standard use case' do
      subject {
        thread_last(
          -> (x) { x } | 1,
          -> (x, y) { x + y } | 2,
          -> (x, y, z) { x + y + z } | 3 | 4
        )
      }

      it { is_expected.to eq 10 }
    end

    context 'One args proc' do
      subject {
        thread_last(
          -> (x) { x } | 1,
          -> (x) { x * 2 },
          -> (x) { x / 2 },
        )
      }

      it { is_expected.to eq 1 }
    end

    context 'First function argument nothing' do
      subject {
        thread_last(
          -> { 1 }
        )
      }

      it { is_expected.to eq 1 }
    end

    context 'Second function only one argument' do
      subject {
        thread_last(
        -> { 1 },
        -> (x) { x }
        )
      }

      it { is_expected.to eq 1 }
    end

    context 'Maybe Maybe MonaXX' do
      subject {
        thread_last(
          -> (x) { x } | 1,
          -> (_) { nil },
          -> (x) { x },
        )
      }

      it { is_expected.to be_nil }
    end

    context 'alias' do
      subject {
        −✈✈(
          -> (x) { x } | 1,
          -> (x, y) { x + y } | 2,
          -> (x, y, z) { x + y + z } | 3 | 4
        )
      }

      it { is_expected.to eq 10 }
    end
  end

  describe 'thread_frist' do
    context 'Standard use case' do
      subject {
        thread_first(
          [1, 2, 3, 4],
          -> (x) { x.select{|e| e.even? } },
          -> (x, y) { x.map{|e| e * y } } | 2,
          -> (x) { x.inject(0){|result, e| result + e } }
        )
      }

      it { is_expected.to eq 12 }
    end
  end

  describe 'thread_as' do
    context 'Standard use case' do
      subject {
        thread_as(:foo,
          -> (x) { x.select{|e| e.even? } } & :foo,
          -> (x, y) { x.map{|e| e * y } } & :foo | 2,
          -> (x) { x.inject(0){|result, e| result + e } } & :foo
        ).call [1, 2, 3, 4]
      }

      it { is_expected.to eq 12 }
    end
  end

  describe 'ireko' do
    subject {
      thread_first(
        ['aaa', 'bbb', 'ccc', 'ddd'],
        ->(x) { x.map(&:upcase) },
        thread_as(:xs,
          ->(xs) { xs.map{|x| "Hello #{x}!!" } } & :xs
        )
      )
    }

    it { is_expected.to eq ['Hello AAA!!', 'Hello BBB!!', 'Hello CCC!!', 'Hello DDD!!'] }
  end

  describe '_map, _select, _inject' do
    context 'macro' do
      subject {
        thread_last(
          [1, 2, 3, 4],
          _select(&:even?),
          _map(-> (e) { e * 2 }),
          _inject(100, &:+)
        )
      }

      it { is_expected.to eq 112 }
    end

    context 'macro with lambda' do
      subject {
        thread_last(
          [1, 2, 3, 4],
          _select(-> (x) { x.even? } ),
          _map(-> (e) { e * 2 }),
          _inject(100, &:+)
        )
      }

      it { is_expected.to eq 112 }
    end

    context '^ its mean' do
      subject {
        _inject(100, -> (result, e) { result + e }).
          call(_map(-> (e) { e * 2 }).
                 call(_select(-> (e) { e.even? }).
                        call([1, 2, 3, 4])))
      }

      it { is_expected.to eq 112 }
    end

    context '^^ its mean' do
      subject {
        -> (collection) { collection.inject(100) {|result, e| result + e } }.
          call(-> (collection) { collection.map {|e| e * 2 } }.
            call(-> (collection) { collection.select(&:even?) }.
              call([1, 2, 3, 4])))
      }

      it { is_expected.to eq 112 }
    end

    context '^^^ its mean' do
      subject {
        [1, 2, 3, 4].
          select(&:even?).
          map {|e| e * 2}.
          inject(100) {|result, e| result + e }
      }

      it { is_expected.to eq 112 }
    end
  end
end
