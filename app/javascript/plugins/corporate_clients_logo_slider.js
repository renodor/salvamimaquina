// import Swiper JS
import Swiper, { Autoplay } from 'swiper';
Swiper.use([Autoplay]); // https://github.com/JayChase/angular2-useful-swiper/issues/48
import 'swiper/swiper.scss';

const corporateClientsLogoSlider = () => {
  const swiperCarousel = document.querySelector('.swiper');

  if (swiperCarousel) {
    new Swiper('.swiper', {
      // Optional parameters
      loop: true,
      slidesPerView: 1,
      spaceBetween: 30,

      autoplay: {
        delay: 2000,
        disableOnInteraction: false
      },

      breakpoints: {
        576: {
          slidesPerView: 2
        },
        768: {
          slidesPerView: 3
        },
        992: {
          slidesPerView: 4
        },
        1200: {
          slidesPerView: 5
        }
      }
    });
  }
};

export { corporateClientsLogoSlider };

