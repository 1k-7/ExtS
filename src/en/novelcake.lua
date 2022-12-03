-- {"id":75,"ver":"1.0.0","libVer":"1.0.0","author":"Doomsdayrs","dep":["Madara>=2.2.0"]}

return Require("Madara")("https://novelcake.com", {
  id = 75,
  name = "novelcake",
  imageURL = "https://novelcake.com/wp-content/uploads/2017/10/NOVELCAKE_2.png",
  novelListingURLPath = "series",
  ajaxUsesFormData = true,
  hasSearch = true,
	chapterType = ChapterType.HTML,

	shrinkURLNovel = shrinkURL,

  genres = {
    "Action",
    "Adventure",
    "Comedy",
    "Drama",
    "Ecchi",
    "Fantasy",
    "Gender Bender",
    "Harem",
    "Historical",
    "Horror",
    "Josei",
    "Martial Arts",
    "Mature",
    "Mecha",
    "Mystery",
    "Psychological",
    "Romance",
    "School Life",
    "Sci-fi",
    "Seinen",
    "Shoujo",
    "Shounen",
    "Slice of Life",
    "Smut",
    "Sports",
    "Supernatural",
    "Tragedy",
    "Wuxia",
    "Xianxia",
    "Xuanhuan",
    "Yaoi"
  }
})