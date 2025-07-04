module.exports = {
  content: [
    "C:\\Users\\xkking\\Documents\\new-actorsoffice\\new-theactorsoffice\\include/**/*.cfm"
  ],
  css: [
    "C:\\Users\\xkking\\Documents\\new-actorsoffice\\new-theactorsoffice\\app\\assets\\css\\app.min.css"
  ],
  output: "C:\\Users\\xkking\\Documents\\new-actorsoffice\\new-theactorsoffice\\app\\assets\\css\\purged\\",
  safelist: {
    standard: [],
    deep: [],
    greedy: []
  },
  defaultExtractor: (content) => content.match(/[\w-/:]+(?<!:)/g) || []
};
