namespace :update_hotel do
  desc "１日に１回、ホテル情報のスクレイピング結果よりDBを更新"

  task :exec => :environment do
    p "tasc start"
    start_time = Time.now
    @format_scrapings = Array.new
    PREFECTURES.each_value do |pre_word|
      p "#{pre_word} is scraping end!"
      # next if pre_word != ""
      @scraping = Hash.new
      scraping = Scraping::Html.new
      scraping.open(pre_word, nil)
      @scraping = scraping.html

      format_scraping = Hash.new{|h,k| h[k]={Jalan: nil,Rakuten: nil,Ikkyu: nil}}
      @scraping.each do |site_name,scr_arr|
        scr_arr.each do |hotel_info|
          hotel_name = NKF::nkf('-WwZ0', hotel_info[1][:title] )
          format_scraping[hotel_name][site_name.to_sym] = hotel_info[1]
        end
      end
      @format_scrapings << format_scraping
    end

    Hotel.transaction do
      # データを更新するために、一度レコードを全削除（hotels,plans）
      Hotel.destroy_all
      Plan.destroy_all

      # scrapingをもとにhotels,plansを登録
      @format_scrapings.each do |fs|
        fs.each do |h_name, h_info|
          Hotel.save_hotel_by_scraping(h_name, h_info)
        end
      end
    end
    p "task end"
    p "処理時間 #{Time.now - start_time}s"
  end

end
