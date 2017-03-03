class SequenceManager
  def initialize(klass, options)
    @managed  = klass

    @start    = options[:start]
    @usage    = options[:usage]
    @force    = options[:force]
    @column   = options[:column]
    @readonly = options[:readonly]
  end

  def last_numbered_record
    @managed
      .where.not(@column => nil)
      .reorder("LENGTH(#{@column}) DESC, #{@column} DESC")
      .first
  end

  def next_number
    return sequence.next_value if sequence

    last = last_numbered_record
    return @start if last.blank?

    number_of(last).succ
  end

  def unique_predictable
    last  = last_numbered_record
    value = @start
    value = number_of(last).succ unless last.blank?
    value = value.succ while @managed.find_by(@column => value)
    value
  end

  def load_predictable_into(record)
    return true if @force && number_of(record).present?
    set_number(record, unique_predictable)
    true
  end

  def load_reliable_into(record)
    return true if !@force && number_of(record)

    unless sequence
      set_number(record, unique_predictable)
      return true
    end

    value = sequence.next_value!
    value = sequence.next_value! while @managed.find_by(@column => value)
    record.send(:"#{@column}=", value)
    true
  end

  def set_number(record, value)
    record.send(:"#{@column}=", value)
  end

  def number_of(record)
    record.send(@column)
  end

  def sequence
    @sequence ||= Sequence.of(@usage)
  end
end