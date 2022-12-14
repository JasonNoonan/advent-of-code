defmodule AdventOfCode.Day02 do
  def part1(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.reduce(
      [],
      fn curr, acc ->
        [enemy, me] = String.split(curr)
        enemy = get_shape(enemy)
        me = get_shape(me)

        score =
          shoot(enemy, me)
          |> get_final_score(me)

        [score | acc]
      end
    )
    |> Enum.sum()
  end

  def part2(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.reduce(
      [],
      fn curr, acc ->
        [enemy, desired_result] = String.split(curr)
        enemy = get_shape(enemy)

        me =
          desired_result
          |> get_action()
          |> get_shape_to_achieve_result(enemy)

        score =
          shoot(enemy, me)
          |> get_final_score(me)

        [score | acc]
      end
    )
    |> Enum.sum()
  end

  def get_shape(x) when x in ["A", "X"], do: :rock
  def get_shape(x) when x in ["B", "Y"], do: :paper
  def get_shape(x) when x in ["C", "Z"], do: :scissors

  def get_action("X"), do: :lose
  def get_action("Y"), do: :draw
  def get_action("Z"), do: :win

  def get_shape_value(shape) do
    case shape do
      :rock -> 1
      :paper -> 2
      :scissors -> 3
    end
  end

  def get_final_score(result, shape), do: get_result_value(result) + get_shape_value(shape)

  def get_result_value(:win), do: 6
  def get_result_value(:draw), do: 3
  def get_result_value(:lose), do: 0

  def win(shape) do
    case shape do
      :rock -> :paper
      :paper -> :scissors
      :scissors -> :rock
    end
  end

  def draw(shape), do: shape

  def lose(shape) do
    case shape do
      :rock -> :scissors
      :paper -> :rock
      :scissors -> :paper
    end
  end

  def get_shape_to_achieve_result(result, target) do
    case result do
      :win -> win(target)
      :draw -> draw(target)
      :lose -> lose(target)
    end
  end

  def(shoot(opp, :rock)) do
    case opp do
      :rock -> :draw
      :paper -> :lose
      :scissors -> :win
    end
  end

  def shoot(opp, :paper) do
    case opp do
      :rock -> :win
      :paper -> :draw
      :scissors -> :lose
    end
  end

  def shoot(opp, :scissors) do
    case opp do
      :rock -> :lose
      :paper -> :win
      :scissors -> :draw
    end
  end
end
