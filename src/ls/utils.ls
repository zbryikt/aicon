utils =
  postify: (g) -> (for k of g => "#{k}=#{g[k]v or g[k]}")join "&"
