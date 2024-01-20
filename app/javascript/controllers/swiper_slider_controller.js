import { Controller } from "@hotwired/stimulus"
import Swiper from 'swiper';

export default class extends Controller {
  static values = {
    options: Object,
    slides: Array
  }

  connect() {
    // Initialize swiper instance with the slider options
    const swiperSlider = new Swiper(this.element, {
      spaceBetween: this.optionsValue.spaceBetweenSlides,

      navigation: this.optionsValue.navigation ? { nextEl: '.swiper-next', prevEl: '.swiper-prev' } : false,
      pagination: this.optionsValue.pagination ? { el: '.swiper-pagination', clickable: true } : false,

      autoplay: {
        enabled: this.optionsValue.autoplay,
        delay: this.optionsValue.delayBetweenSlides,
        disableOnInteraction: false
      },

      breakpoints: {
        576: {
          slidesPerView: this.optionsValue.imagePerSlideS
        },
        768: {
          slidesPerView: this.optionsValue.imagePerSlideM
        },
        992: {
          slidesPerView: this.optionsValue.imagePerSlideL
        },
        1200: {
          slidesPerView: this.optionsValue.imagePerSlideXl
        },
        1400: { // We don't use this breakpoint for imagePerSlide config, but use it to display the slide image at the correct size
          slidesPerView: this.optionsValue.imagePerSlideXl
        }
      }
    });

    if (this.optionsValue.disableLoop) { swiperSlider.disable(); }

    this.displayBreakpointSlides(swiperSlider)

    // Whenever windows size hit a new breakpoint, hide/display slides of the correct size
    swiperSlider.on('breakpoint', () => (this.displayBreakpointSlides(swiperSlider)))
  }

  // Hide/display slides of the correct size
  displayBreakpointSlides(slider) {
    slider.params.loop = false
    slider.removeAllSlides()
    slider.appendSlide(this.slidesValue.map(({ link, images, alt }) => {
      return `<div class="swiper-slide centered-flexbox relative">
                <img src="${images[slider.currentBreakpoint]}" alt="${decodeURIComponent(alt).replace(/\+/g, ' ')}">
                ${link ? `<a href="${decodeURIComponent(link)} class="full-absolute""></a>` : ''}
              </div>`
    }))
    slider.updateSlides()
    slider.params.loop = true
  };
}
