[![Build Status](https://travis-ci.org/t-kunou/conamon.svg?branch=master)](https://travis-ci.org/t-kunou/conamon)
[![Code Climate](https://codeclimate.com/github/t-kunou/conamon/badges/gpa.svg)](https://codeclimate.com/github/t-kunou/conamon)
[![Test Coverage](https://codeclimate.com/github/t-kunou/conamon/badges/coverage.svg)](https://codeclimate.com/github/t-kunou/conamon/coverage)

# conamon (ClojureLikeThreadingMacro)

ClojureのスレッディングマクロっぽいものをRubyでもつかえるようにするという実験的なシロモノです。

## スレッディングマクロとは

Clojureで書いた普通のS式で

```clojure
(reduce + 100
  (map #(* %1 2)
      (filter even?
            [1 2 3 4])))
```

の様なコードが有ったとき、4行目、3行目、2行目、1行目の順に関数が実行されます。

これをスレッディングマクロを使用すると

```clojure
(->>
  [1 2 3 4]
  (filter even?)
  (map #(* %1 2))
  (reduce + 100))
```

の様に書くことができ、上から順に関数が実行されます。

## このgemで今出来ること

このgem(になる予定のブツ)では、上述したClojureコードと同等の事を行うRubyのコード

```ruby
-> (collection) { collection.inject(100) {|result, e| result + e } }.
  call(-> (collection) { collection.map {|e| e * 2 } }.
    call(-> (collection) { collection.select(&:even?) }.
      call([1, 2, 3, 4])))
```

を、下記の様に書くことが出来ます。

```ruby
thread_last(
  [1, 2, 3, 4],
  _select(&:even?),
  _map(-> (e) { e * 2 }),
  _inject(100, -> (result, e) { result + e })
)
```

ちなみに、このコードはラムダを使わずに普通に書くとこうです。

```ruby
[1, 2, 3, 4].
  select(&:even?).
  map {|e| e * 2}.
  inject(100) {|result, e| result + e }
```

~~これで十分ですよね:smile:~~

## このgemでまだ出来ないこと
- as-> が本家のものに比べて不完全です
- some->, some->>, cond->, cond->> に未対応です
- いちいちラムダ式を書くのが面倒なので糖衣構文を提供したいのですが未着手です
