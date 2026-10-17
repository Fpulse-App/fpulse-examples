export default defineNuxtConfig({
  app: {
    head: {
      script: [
        { src: 'https://fpulse.app/w/YOUR_WIDGET_ID.js', defer: true }
      ]
    }
  }
})
