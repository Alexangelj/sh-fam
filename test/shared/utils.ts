export function log(val: string, id?: string) {
  console.log(id ? id : "", val)
}

export function parseTokenURI(uri: string) {
  const json = Buffer.from(uri.substring(29), "base64").toString() //(uri.substring(29));
  const result = JSON.parse(json)
  return result
}

export function parseImage(json: any) {
  const imageHeader = "data:image/svg+xml;base64,"
  const image = Buffer.from(
    json.image.substring(imageHeader.length),
    "base64"
  ).toString()
  return image
}
