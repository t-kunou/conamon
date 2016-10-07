require 'clojure_like_threading_macro/bind_marker'

module ThreadingMacro
  def thread_last(*procs)
    threading_with_index(procs, ->(args, result) { args ? args.insert(-1, result) : [result] })
  end
  alias_method :_77, :thread_last
  alias_method '−＞＞', :thread_last
  alias_method '−✈✈', :thread_last

  def thread_first(*procs)
    threading_with_index(procs, ->(args, result) { args ? args.insert(0, result) : [result] })
  end
  alias_method :_7, :thread_last
  alias_method '−＞', :thread_last
  alias_method '−✈', :thread_last

  def thread_as(_, *procs)
    -> (x) {
      threading_with_index([x] + procs,
        -> (args, result) {
          args.map{|arg|
            arg.is_a?(BindMarker) ? result : arg
          }
        }
      )
    }
  end

  private

  def threading_with_index(procs, binding_strategy)
    procs[1..-1].inject(first_value(procs.first)) {|result, proc|
      args = binding_strategy.call(proc.binding_args, result)

      (args || []).inject(proc) {|p, arg|
        p.curry[arg]
      }
    }
  end

  def first_value(proc_or_value)
    proc = proc_or_value.is_a?(Proc) ? proc_or_value : -> { proc_or_value }

    if proc.has_binding_args?
      proc.binding_args.inject(proc) {
        |binding_proc, arg| binding_proc.curry[arg]
      }
    else
      proc.call
    end
  end

  def _map(proc)
    -> (collection) {
      -> (xs) { xs.map{|x| proc.call(x)} }.call(collection)
    }.curry
  end

  def _select(proc = nil, &block)
    -> (collection) {
      -> (xs) {
        if block_given?
          xs.select(&block)
        else
          xs.select{|x| proc.call(x)}
        end
      }.call(collection)
    }.curry
  end

  def _inject(init, proc = nil, &block)
    -> (collection) {
      -> (xs) {
        if block_given?
          xs.inject(init, &block)
        else
          xs.inject(init) {|accumulator, x| proc.call(accumulator, x)}
        end
      }.call(collection)
    }.curry
  end
end