require 'rspec'
require 'clojure_like_threading_macro'

describe 'ClojureLikeThreadingMacro' do
  include ClojureLikeThreadingMacro

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
        thread_as([1, 2, 3, 4], :foo,
          -> (x) { x.select{|e| e.even? } } & :foo,
          -> (x, y) { x.map{|e| e * y } } & :foo | 2,
          -> (x) { x.inject(0){|result, e| result + e } } & :foo
        )
      }

      it { is_expected.to eq 12 }
    end
  end
end