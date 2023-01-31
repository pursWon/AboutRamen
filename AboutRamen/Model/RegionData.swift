import Foundation

struct RegionData {
    let cities: [String] = ["서울시", "강원도", "경기도", "경상도", "광주시", "대구시", "대전시", "부산시", "울산시", "인천시", "전라도", "충청도", "제주시"]
    
    let seoul: [String] = ["강남구", "강동구", "강북구", "강서구", "관악구", "광진구", "구로구", "금천구", "노원구", "도봉구", "동대문구", "동작구", "마포구", "서대문구", "서초구", "성동구", "성북구", "송파구", "양천구", "영등포구", "용산구", "은평구", "종로구", "중구", "중랑구"]

    let gangwon: [String] = ["강릉시", "동해시", "삼척시", "속초시", "양구군", "원주시", "춘천시", "태백시", "홍청군"]
    
    let gyeonggi: [String] = ["강화군", "고양시", "과천시", "광명시", "광주시", "구리시", "군포시", "김포시", "남양주시", "동두천시", "부천시", "성남시", "수원시", "시흥시", "안산시", "안성시", "안양시", "양주시", "양평군", "여주시", "오산시", "옹진군", "용인시", "의왕시", "의정부시", "이천시", "파주시", "평택시", "포천시", "하남시"]
    
    let gyeongsang: [String] = ["거제시", "거창군", "경산시", "경주시", "고성군", "구미시",  "기장군", "김천시", "김해시", "남해군", "마산시", "문경시", "밀양시", "사천시", "상주시",  "안동시", "양산시", "영주시", "영천시", "울진군", "진주시", "진해시", "창원시", "칠곡군", "통영시", "포항시"]
    
    let gwangju: [String] = ["광산구", "남구", "동구", "북구", "서구"]
    
    let daegu: [String] = ["달서구", "수성구", "남구", "달성군", "동구", "북구", "서구", "중구"]
    
    let daejeon: [String] = ["대덕구", "동구", "서구", "유성구", "중구"]
    
    let busan: [String] = ["강서구", "금정구", "남구", "동구", "동래구", "부산진구", "북구", "사상구", "사하구", "서구", "수영구", "연제구", "영도구", "중구", "해운대구", "기장군"]
    
    let ulsan: [String] = ["남구", "동구", "북구", "중구"]
    
    let incheon: [String] = ["강화군", "계양구", "남구", "남동구", "동구", "미추홀구", "부평구", "서구", "연수구", "중구"]
    
    let jeolla: [String] = ["광양시", "군산시", "김제시", "나주시", "남원시", "목포시", "무안군", "무주군", "보성군", "부안군", "순천시", "여수시", "영광군", "익산시", "전주시", "정읍시", "해남군", "화순군"]
    
    let chungcheong: [String] = ["공주시", "괴산군", "금산군", "세종시", "논산시", "단양군", "당진시", "보령시", "부여군", "서산시", "아산시", "예산군", "제천시", "조치원읍", "증평군", "천안시", "청주시", "충주시", "홍성군"]
    
    let jeju: [String] = ["서귀포시", "제주시"]
    
    // 경도, 위도 데이터
    let LngLat: [String : (Double, Double)] = ["서울시 강남구" : (127.0495556, 37.514575), "서울시 강동구" : (127.1258639, 37.52736667)
                                               , "서울시 강북구" : (127.0277194, 37.63695556), "서울시 강서구" : (126.8516675, 37.54815556),
                                               "서울시 관악구" : (126.9538444, 37.47538611), "서울시 광진구" : (127.0845333, 37.53573889),
                                               "서울시 구로구" : (126.8895972, 37.49265), "서울시 금천구" : (126.9041972, 37.44910833),
                                               "서울시 노원구" : (127.0583889, 37.65146111), "서울시 도봉구" : (127.0495222, 37.66583333),
                                               "서울시 동대문구" : (127.0421417, 37.571625), "서울시 동작구" : (126.941575, 37.50965556),
                                               "서울시 마포구" : (126.9105306, 37.56070556), "서울시 서대문구" : (126.9388972, 37.5763667),
                                               "서울시 서초구" : (127.0348111, 37.48078611), "서울시 성동구" : (127.039, 37.56061111 ),
                                               "서울시 성북구" : (127.0203333, 37.58638333), "서울시 송파구" : (127.1079306, 37.51175556),
                                               "서울시 양천구" : (126.8687083, 37.51423056), "서울시 영등포구" : (126.8983417, 37.52361111),
                                               "서울시 용산구" : (126.9675222, 37.53609444), "서울시 은평구" : (126.9312417, 37.59996944),
                                               "서울시 종로구" : (126.9816417, 37.57037778), "서울시 중구" : (126.9996417, 37.56100278),
                                               "서울시 중랑구" : (127.0947778, 37.60380556), "강원도 강릉시" : (128.8784972, 37.74913611), "강원도 동해시" : (129.1166333, 37.52193056), "강원도 삼척시" : (129.1674889, 37.44708611), "강원도 속초시" : (128.5941667, 38.204275), "강원도 양구군" : (127.9922444, 38.10729167), "강원도 원주시" : (127.9220556, 37.33908333), "강원도 정선군" : (128.6630861, 37.37780833), "강원도 춘천시" : (127.7323111, 37.87854167), "강원도 태백시" : (128.9879972, 37.16122778), "강원도 홍천군" : (127.8908417, 37.69442222), "경기도 강화군" : (126.49, 37.74385833), "경기도 고양시" : (126.7770556, 37.65590833), "경기도 과천시" : (126.9898, 37.42637222), "경기도 광명시" : (126.8667083, 37.47575), "경기도 광주시" : (127.2577861, 37.41450556), "경기도 구리시" : (127.1318639, 37.591625), "경기도 군포시" : (126.9375, 37.35865833), "경기도 김포시" : (126.7177778, 37.61245833), "경기도 남양주시" : (127.2186333, 37.63317778), "경기도 동두천시" : (127.0626528, 37.90091667), "경기도 부천시" : (126.766, 37.5035917), "경기도 성남시" : (127.1477194, 37.44749167), "경기도 수원시" : (127.0122222, 37.30101111), "경기도 시흥시" : (126.8050778, 37.37731944), "경기도 안산시" : (126.8468194, 37.29851944), "경기도 안성시" : (127.2818444, 37.005175), "경기도 안양시" : (126.9533556, 37.3897), "경기도 양주시" : (127.0478194, 37.78245), "경기도 양평군" : (127.4898861, 37.48893611), "경기도 여주시" : (127.6396222, 37.29535833), "경기도 오산시" : (127.0796417, 37.14691389), "경기도 옹진군" : (126.6388889, 37.443725), "경기도 용인시" : (127.2038444, 37.23147778), "경기도 의왕시" : (126.9703889, 37.34195), "경기도 의정부시" : (127.0358417, 37.73528889), "경기도 이천시" : (127.4432194, 37.27543611), "경기도 파주시" : (126.7819528, 37.75708333), "경기도 평택시" : (127.1146556, 36.98943889), "경기도 포천시" : (127.2024194, 37.89215556), "경기도 하남시" : (127.217, 37.53649722), "경상도 거제시" : (128.6233556, 34.87735833), "경상도 거창군" : (127.9116556, 35.683625), "경상도 경산시" : (128.7434639, 35.82208889), "경상도 경주시" : (129.2270222, 35.85316944), "경상도 고성군" : (128.3245417, 34.9699), "경상도 구미시" : (128.3467778, 36.11655), "경상도 기장군" : (129.224475, 35.24135), "경상도 김천시" : (128.1158, 36.13689722), "경상도 김해시" : (128.8916667, 35.22550556), "경상도 남해군" : (127.8944667, 34.83455833), "경상도 마산시" : (128.567863, 35.196874), "경상도 문경시" : (128.1890194, 36.58363056), "경상도 밀양시" : (128.7489444, 35.50077778), "경상도 사천시" : (128.0667778, 35.00028333), "경상도 상주시" : (128.1612639, 36.40796944), "경상도 안동시" : (128.7316222, 36.56546389), "경상도 양산시" : (129.0394111, 35.33192778),  "경상도 영주시" : (128.6263444, 36.80293611), "경상도 영천시" : (128.940775, 35.97005278), "경상도 울진군" : (129.4027861, 36.99018611),  "경상도 진주시" : (128.1100000, 35.17703333), "경상도 진해시" : (128.710081, 35.1330600), "경상도 창원시" : (128.6401544, 35.2540033),   "경상도 칠곡군" : (128.4037972, 35.99254722), "경상도 통영시" : (128.4352778, 34.85125833), "경상도 포항시" : (129.3616667, 36.00568611), "광주시 광산구" : (126.793668, 35.13995836), "광주시 남구" : (126.9025572, 35.13301749), "광주시 동구" : (126.9230903, 35.14627776), "광주시 북구" : (126.9010806, 35.1812138), "광주시 서구" : (126.8895063, 35.1525164),
                                               "대구시 달서구" : (128.5350639, 35.82692778), "대구시 수성구" : (128.6328667, 35.85520833), "대구시 남구" : (128.597702, 35.84621351), "대구시 달성군" : (128.4313995, 35.77475029), "대구시 동구" : (128.6355584, 35.88682728), "대구시 북구" : (128.5828924, 35.8858646), "대구시 서구" : (128.5591601, 35.87194054), "대구시 중구" : (128.6061745, 35.86952722), "대전시 대덕구" : (127.4170933, 36.35218384), "대전시 동구" : (127.4548596, 36.31204028), "대전시 서구" : (127.3834158, 36.35707299), "대전시 유성구" : (127.3561363, 36.36405586), "대전시 중구" : (127.421381, 36.32582989), "부산시 강서구" : (128.9829083, 35.20916389), "부산시 금정구" : (129.0943194, 35.24007778), "부산시 남구" : (129.0865, 35.13340833), "부산시 동구" : (129.059175, 35.13589444), "부산시 동래구" : (129.0858556, 35.20187222), "부산시 부산진구" : (129.0553194, 35.15995278), "부산시 북구" : (128.992475, 35.19418056), "부산시 사상구" : (128.9933333, 35.14946667), "부산시 사하구" : (128.9770417, 35.10142778), "부산시 서구" : (129.0263778, 35.09483611), "부산시 수영구" : (129.115375, 35.14246667), "부산시 연제구" : (129.082075, 35.17318611), "부산시 중구" : (129.0345083, 35.10321667), "부산시 해운대구" : (129.1658083, 35.16001944), "부산시 기장군" : (129.2222873, 35.24477541), "울산시 남구" : (129.3301754, 35.54404265), "울산시 동구" : (129.4166919, 35.50516996), "울산시 북구" : (129.361245, 35.58270783) ,"울산시 중구" : (129.3328162, 35.56971228), "인천시 강화군" : (126.4878417, 37.74692907), "인천시 계양구" : (126.737744, 37.53770728), "인천시 남구" : (126.6502972, 37.46369169), "인천시 동구" : (126.6432441, 37.47401607), "인천시 남동구" : (126.7309669, 37.44971062), "인천시 미추홀구" : (126.6502972, 37.46369169), "인천시 부평구" : (126.7219068, 37.50784204), "인천시 서구" : (126.6759616, 37.54546372), "인천시 연수구" : (126.6782658, 37.41038125), "인천시 중구" : (126.6217617, 37.47384843), "전라도 광양시" : (127.6981778, 34.93753611), "전라도 군산시" : (126.7388444, 35.96464167), "전라도 김제시" : (126.8827528, 35.800575), "전라도 나주시" : (126.7128667, 35.01283889), "전라도 남원시" : (127.3925, 35.41325556), "전라도 목포시" : (126.3944194, 34.80878889), "전라도 무안군" : (126.4837, 34.98736944), "전라도 보성군" : (127.0820889, 34.76833333), "전라도 부안군" : (126.7356778, 35.72853333), "전라도 순천시" : (127.4893306, 34.94760556), "전라도 여수시" : (127.6643861, 34.75731111), "전라도 영광군" : (126.5140861, 35.27416667), "전라도 익산시" : (126.9598528, 35.945275), "전라도 전주시" : (127.1219194, 35.80918889), "전라도 정읍시" : (126.8581111, 35.56687222), "전라도 해남군" : (126.6012889, 34.57043611), "전라도 화순군" : (126.9885667, 35.06148056), "충청도 공주시" : (127.1211194, 36.44361389), "충청도 괴산군" : (127.7888306, 36.81243056), "충청도 금산군" : (127.4903083, 36.10586944), "충청도 세종시" : (127.289448, 36.479522), "충청도 논산시" : (127.1009111, 36.18420278), "충청도 단양군" : (128.3678417, 36.98178056), "충청도 당진시" : (126.6302528, 36.89075), "충청도 보령시" : (126.6148861, 36.330575), "충청도 부여군" : (126.9118639, 36.27282222), "충청도 서산시" : (126.4521639, 36.78209722), "충청도 아산시" : (127.0046417, 36.78710556), "충청도 예산군" : (126.850875, 36.67980556), "충청도 제천시" : (128.1931528, 37.12976944), "충청도 조치원읍" : (127.298399, 36.604528), "충청도 증평군" : (127.5832889, 36.78218056), "충청도 천안시" : (127.1524667, 36.804125), "충청도 청주시" : (127.5117306, 36.58399722), "충청도 충주시" : (127.9281444, 36.98818056),  "충청도 홍성군" : (126.6629083, 36.59836111), "제주시 서귀포시" : (126.5125556, 33.25235), "제주시 제주시" : (126.5332083, 33.49631111)
    ]
}
