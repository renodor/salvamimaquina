// import Swiper JS
import Swiper, { Autoplay, Navigation, Pagination, Manipulation } from 'swiper';
Swiper.use([Autoplay, Navigation, Pagination, Manipulation]); // https://github.com/JayChase/angular2-useful-swiper/issues/48

const swiperSlider = () => {
  const swiperCarousel = document.querySelector('.swiper');

  if (swiperCarousel) {
    const swiperOptions = swiperCarousel.dataset;
    const swiper = new Swiper('.swiper', {
      loop: swiperCarousel.dataset.loop === 'true',
      spaceBetween: 10,

      navigation: swiperOptions.navigation === 'true' ? { nextEl: '.swiper-next', prevEl: '.swiper-prev' } : false,
      pagination: swiperOptions.pagination === 'true' ? { el: '.swiper-pagination', clickable: true } : false,

      autoplay: {
        enabled: swiperOptions.autoplay === 'true',
        delay: parseInt(swiperOptions.delayBetweenSlides),
        disableOnInteraction: false
      },

      breakpoints: {
        576: {
          slidesPerView: parseInt(swiperOptions.imagePerSlideS)
        },
        768: {
          slidesPerView: parseInt(swiperOptions.imagePerSlideM)
        },
        992: {
          slidesPerView: parseInt(swiperOptions.imagePerSlideL)
        },
        1200: {
          slidesPerView: parseInt(swiperOptions.imagePerSlideXl)
        }
      }
    });

    swiper.appendSlide('<div class="swiper-slide">Slide 10"</div>');
  }
};

export { swiperSlider };

