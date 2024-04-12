import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  formatDateInput({ currentTarget, inputType }) {
    if (inputType === 'deleteContentBackward' && currentTarget.value.match(/^\d{2}\s\/$/g)) {
      currentTarget.value = currentTarget.value.replace(/^(\d)\d\s\/$/g, '$1')
      return
    }

    currentTarget.value = currentTarget.value.replace(
      /[^\d\/]|^[\/]*$/g, '' // To allow only and `/`
    ).replace(
      /^(1\/)$/g, '01 / ' // 1/ > 01 /
    ).replace(
      /^([2-9])$/g, '0$1 / ' // 3 > 03/
    ).replace(
      /^(0[1-9]|1[0-2])$/g, '$1 / ' // 11 > 11/
    ).replace(
      /^([0-1])([3-9])$/g, '0$1 / $2' // 13 > 01/3
    ).replace(
      /^(0?[1-9]|1[0-2])([0-9]{2})$/g, '$1 / $2' // 141 > 01/41
    ).replace(
      /^([0]+)\/|[0]+$/g, '0' // 0/ > 0 and 00 > 0
    ).replace(
      /^(\d+)\s*\/\s*(\d*)$/g, '$1 / $2'
    ).replace(
      /\/\//g, ' / ' // Prevent entering more than 1 `/`
    );
  }
}
