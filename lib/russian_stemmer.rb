# app/lib/russian_stemmer.rb
class RussianStemmer
  SUFFIXES = %w[
    ая ам ий ия иям иями иях его ого ему ому ие ое ые
    ым ую юю ыми ими ей ой ый ом ем им
    ами ах ями ях ям
    лась лся лось лись вшись вший вшее вшей вшими вших
    ейше ейшее ейшей ейшими ейших ейшего ейшему ейшем
    щий щее щей щего щему щем щими щих
    ющий ющая ющее ющие ющего ющей ющем ющими ющих
    емом емых емую емой емое емые емый
    нн ость ости остей остью остям остями остях оств оствам оствами остве
    ёк ёв ём ёвши ёвшим ёвшего ёвшему ёвшем ёвшими ёвших
    ировани ированн ирован ировать ировав ировавши ировавший
    ованн ован овать овав овавши овавший
    еванн еванный еванные еванными еванных
    ёванн ёванный ёванные ёванными ёванных
  ].sort_by { |s| -s.length }.freeze

  def self.stem(word)
    word = word.downcase.gsub(/[^а-яё]/, "")
    return word if word.length < 3

    word = word[0...-1] if word.end_with?("ь", "ъ")

    SUFFIXES.each do |suffix|
      if word.end_with?(suffix) && (word.length - suffix.length) >= 3
        word = word[0...-suffix.length]
        word = word[0...-1] if word.end_with?("ь", "ъ")
        break
      end
    end
    word
  end
end
