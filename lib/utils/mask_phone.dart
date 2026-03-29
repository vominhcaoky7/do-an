String maskPhone(String phone) {
  if (phone.length <= 6) return phone;

  return phone.substring(0, 3) + "****" + phone.substring(phone.length - 3);
}
