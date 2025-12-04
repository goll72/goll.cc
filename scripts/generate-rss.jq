"
<rss version=\"2.0\" xmlns:atom=\"http://www.w3.org/2005/Atom\">
  <channel>
    <title>goll.cc</title>
    <link>https://goll.cc\($prefix)</link>
    <description>
      Blog posts on random topics (maybe math and Linux too)
    </description>
    <language>\(if $prefix == "/" then "en" else $prefix[1:2] end)</language>
    <pubDate>\($date)</pubDate>
    <generator>jq</generator>
    <atom:link href=\"https://goll.cc\($prefix)rss.xml\" rel=\"self\" type=\"application/rss+xml\" />
    \(.[$prefix] | map(
      "
      <item>
        <title>\(.[1])</title>
        <link>https://goll.cc\($prefix[0:-1])\(.[0])</link>
        <description>\(.[2])</description>
      </item>
      "
    ) | add)
  </channel>
</rss>
" | trim
