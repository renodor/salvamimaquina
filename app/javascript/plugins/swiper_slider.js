// import Swiper JS
import Swiper, { Autoplay, Navigation, Pagination, Manipulation } from 'swiper';
Swiper.use([Autoplay, Navigation, Pagination, Manipulation]); // https://github.com/JayChase/angular2-useful-swiper/issues/48

const swiperSlider = () => {
  const swiperCarousel = document.querySelector('.swiper');

  if (swiperCarousel) {
    const swiperOptions = swiperCarousel.dataset;
    const swiper = new Swiper('.swiper', {
      spaceBetween: parseInt(swiperOptions.spaceBetweenSlides),

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

    const desktopSlideUrls = JSON.parse(swiperCarousel.dataset.desktopSlides);
    const mobileSlideUrls = JSON.parse(swiperCarousel.dataset.mobileSlides);

    const addSlides = (slideUrls) => {
      slideUrls.forEach((slideUrl) => swiper.appendSlide(`<div class="swiper-slide centered-flexbox"><img src="${slideUrl}" /></div>`));
    };

    if (mobileSlideUrls.length > 0) {
      const addRelevantTypeToSlider = () => {
        if (window.innerWidth > 575) {
          swiper.wrapperEl.dataset.type = 'desktop';
        } else {
          swiper.wrapperEl.dataset.type = 'mobile';
        }
      };

      const addRelevantSlides = () => {
        if (swiper.wrapperEl.dataset.type === 'desktop') {
          swiper.removeAllSlides();
          addSlides(desktopSlideUrls);
        } else {
          swiper.removeAllSlides();
          addSlides(mobileSlideUrls);
        }
      };

      addRelevantTypeToSlider();
      addRelevantSlides();


      swiper.on('breakpoint', () => {
        if (window.innerWidth > 575 && swiper.wrapperEl.dataset.type == 'mobile') {
          swiper.wrapperEl.dataset.type = 'desktop';
          addRelevantSlides();
        } else if (window.innerWidth <= 575 && swiper.wrapperEl.dataset.type == 'desktop') {
          swiper.wrapperEl.dataset.type = 'mobile';
          addRelevantSlides();
        }
      });
    } else {
      addSlides(desktopSlideUrls);
    }
  }
};

export { swiperSlider };

