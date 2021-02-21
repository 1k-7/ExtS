-- {"id":86802,"ver":"1.0.0","libVer":"1.0.0","author":"TechnoJo4"}

local baseURL = "https://www.scribblehub.com"
local qs = Require("url").querystring

-- Same CSS as WuxiaWorld for good measure,
-- because first novel and chapter I opened also used tables for layout
-- PR a good style if any other elements are used for layout in any other novels
local css = [[
table {
    background: #004b7a;
    margin: 10px auto;
    width: 90%;
    border: none;
    box-shadow: 1px 1px 1px rgba(0, 0, 0, .75);
    border-collapse: separate;
    border-spacing: 2px;
}]]

local function shrinkURL(url)
    return url:gsub("^.-scribblehub%.com", "")
end

local function expandURL(url)
    return baseURL .. url
end

local default_order = {
    [1] = 2, -- Popularity -> Weekly
    [2] = 4, -- Favorites -> All Time
    [3] = 2, -- Activity -> Weekly
    [4] = 2, -- Readers -> Weekly
    [5] = 1, -- Rising -> Daily
}

local FILTER_SORT = 2
local FILTER_ORDER = 3

local MTYPE = MediaType("application/x-www-form-urlencoded")

local function parse(doc)
    return map(doc:selectFirst("#page"):select(".wi_fic_wrap .search_main_box"), function(v)
        local t = v:selectFirst(".search_body .search_title a")
        return Novel {
            title = t:text(),
            link = t:attr("href"):match("/series/(%d+)"),
            imageURL = v:selectFirst(".search_img img"):attr("src")
        }
    end)
end

return {
    id = 86802,
    name = "ScribbleHub",
    baseURL = baseURL,
    imageURL = "https://github.com/shosetsuorg/extensions/raw/dev/src/main/resources/icons/ScribbleHub.png",

    listings = {
        Listing("Novels", true, function(data)
            local sort = data[FILTER_SORT] and data[FILTER_SORT] + 1 or 1
            local order = data[FILTER_ORDER]
                            and data[FILTER_ORDER] + 1
                            or default_order[sort]

            return parse(GETDocument(qs({
                sort = sort, order = order
            }, baseURL .. "/series-ranking/")))
        end)
    },

    filters = {
        DropdownFilter(FILTER_SORT, "Sort by", { "Popularity", "Favorites", "Activity", "Readers", "Rising" }),
        DropdownFilter(FILTER_ORDER, "Order", { "Daily", "Weekly", "Monthly", "All Time" })
    },

    shrinkURL = shrinkURL,
    expandURL = expandURL,

    parseNovel = function(url, loadChapters)
        local doc = GETDocument(baseURL.."/series/"..url.."/a/")
        local wrap = doc:selectFirst(".wi_fic_wrap")
        local novel = wrap:selectFirst(".novel-container")
        local r = wrap:selectFirst(".wi-fic_r-content")
        local s = r:selectFirst(".copyright ul"):children()
        s = s:get(s:size() - 1):children()
        s = s:get(s:size() - 1)
        s = s:ownText()
        if s:match("Ongoing") then
            s = NovelStatus.ONGOING
        elseif s:match("Complete") then
            s = NovelStatus.COMPLETED
        else
            s = NovelStatus.UNKNOWN
        end

        local text = function(v) return v:text() end
        local info = NovelInfo {
            title = novel:selectFirst(".fic_title"):text(),
            imageUrl = novel:selectFirst(".novel-cover img"):attr("src"),
            description = wrap:selectFirst(".wi_fic_desc"):text(),
            genres = map(wrap:selectFirst(".wi_fic_genre"):select("a"), text),
            tags = map(wrap:selectFirst(".wi_fic_showtags"):select("a"), text),
            authors = { r:selectFirst("div[property=author] .auth_name_fic"):text() },
            status = s
        }

        if loadChapters then
            local body = RequestBody("action=wi_gettocchp&strSID="..url.."&strmypostid=0&strFic=yes", MTYPE)
            local cdoc = RequestDocument(POST("https://www.scribblehub.com/wp-admin/admin-ajax.php", nil, body))
            local count = tonumber(cdoc:selectFirst("ol"):attr("count"))
            local chapters = AsList(map(cdoc:select("a"), function(v, i)
                return NovelChapter {
                    order = count-i,
                    title = v:text(),
                    link = shrinkURL(v:attr("href"))
                }
            end))
            Reverse(chapters)
            info:setChapters(chapters)
        end

        return info
    end,

    getPassage = function(url)
        local chap = GETDocument(baseURL..url):getElementById("chp_raw")

        -- remove empty <p> tags
        local toRemove = {}
        chap:traverse(NodeVisitor(function(v)
            print(v)
            if v:tagName() == "p" and v:text() == " " then
                toRemove[#toRemove+1] = v
            end
        end, nil, true))
        for _,v in pairs(toRemove) do
            v:remove()
        end

        return pageOfElem(chap, false, css)
    end,

    search = function(data)
        return parse(GETDocument(qs({
            s = data[QUERY], post_type = "fictionposts"
        }, baseURL .. "/")))
    end,
    isSearchIncrementing = false
}
