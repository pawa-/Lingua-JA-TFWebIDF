use strict;
use warnings;
use utf8;
use Lingua::JA::TFWebIDF;
use Test::More;
use Test::Requires qw/TokyoCabinet/;

binmode Test::More->builder->$_ => ':utf8'
    for qw/output failure_output todo_output/;


my %config = (
    appid             => 'test',
    driver            => 'TokyoCabinet',
    df_file           => './df/utf8.tch',
    fetch_df          => 0,
    pos1_filter       => [qw/非自立 代名詞 数 ナイ形容詞語幹 副詞可能 サ変接続/],
    pos2_filter       => [],
    pos3_filter       => [],
    ng_word           => [qw/編集 消去/],
    term_length_min   => 0,
    term_length_max   => 20,
    concat_max        => 0,
);

my %concat0 = (
    '言語処理'         => [ qw/言語処理/        ],
    'p-model'          => [ qw/model p/         ],
    's+xx+yba'         => [ qw/yba xx s/        ],
    'p-'               => [ qw/p/               ],
    'p-p'              => [ qw/p/               ], # p is integrated. -> tf = 2
    'p-a'              => [ qw/p a/             ],
    '-pa'              => [ qw/pa/              ],
    '-pawa-'           => [ qw/pawa/            ],
    '-p-a-w-a-'        => [ qw/w p a/           ],
    '-'                => [ qw//                ],
    '---'              => [ qw//                ],
    'A---Z'            => [ qw/Z A/             ],
    'ﾆｬ---'            => [ qw/ﾆｬ/              ],
    'ブック'           => [ qw/ブック/          ],
    'ワーク・ブック'   => [ qw/ワーク ブック/   ],
    'ワーク・・ブック' => [ qw/ワーク ブック/   ],
    '・・ヴェ・・'     => [ qw/ヴェ/            ],
    '世界タービン'     => [ qw/タービン 世界/   ],
    '謎の彼氏X'        => [ qw/彼氏 謎 X/       ],
    'ATH-EC7'          => [ qw/ATH EC/          ], # 7 is filterd
    '0x800ccc0f'       => [ qw/x8 c0 f cc/      ],
    '閉鎖空間'         => [ qw/空間/            ], # 閉鎖 is サ変
    '編集距離'         => [ qw/編集距離/        ],
    '編集・距離'       => [ qw/距離/            ],
    '原稿編集'         => [ qw/原稿/            ], # 編集 is ng_word
    '編集消去'         => [ qw//                ],
    '追加削除'         => [ qw//                ],
    '情報統合思念体'   => [ qw/体 情報/         ],
    '思念体'           => [ qw/体/              ],
    '大学　学会'       => [ qw/学会 大学/       ],
    '大学 学会'        => [ qw/学会 大学/       ],
    '東京-大阪'        => [ qw/大阪 東京/       ],
    '上-下'            => [ qw/下 上/           ],
    'さくらVPS'        => [ qw/VPS さくら/      ],
    'さくらのVPS'      => [ qw/VPS さくら/      ],
    'abra-kada-bra-oil' => [ qw/abra kada oil bra/ ],
    'ワーク・ブック・オブ・グレイセス' => [ qw/グレイセス オブ ワーク ブック/ ],
    ' ワーク ・ ブック ' => [ qw/ワーク ブック/ ],
    ' ワーク ・ブック '  => [ qw/ワーク ブック/ ],
    '心・技・体'         => [ qw/技 体 心/      ],
    'ウ・保'             => [ qw/保/            ],
    'ウ・まずい'         => [ qw//              ],
    '亜'                 => [ qw/亜/            ],
    'SOS団'              => [ qw/団 SOS/        ],
    '2010年'             => [ qw/年/            ],
    'ゴルゴ48'           => [ qw/ゴルゴ/        ],
    '三匹'               => [ qw/匹/            ],
    '朝比奈さん'         => [ qw/朝比奈 さん/   ],
    '図書委員会'         => [ qw/図書 委員会/   ],
    "図書\n委員会"       => [ qw/図書 委員会/   ],
    "図書 委員会"        => [ qw/図書 委員会/   ],
    "図書　委員会"       => [ qw/図書 委員会/   ],
    "SOS-48"             => [ qw/SOS/           ],
    "1・2・3"            => [ qw//              ],
);

my %concat0_suffix_ng = (
    '言語処理'         => [ qw/言語処理/        ],
    'p-model'          => [ qw/model p/         ],
    's+xx+yba'         => [ qw/yba xx s/        ],
    'p-'               => [ qw/p/               ],
    'p-p'              => [ qw/p/               ], # p is integrated. -> tf = 2
    'p-a'              => [ qw/p a/             ],
    '-pa'              => [ qw/pa/              ],
    '-pawa-'           => [ qw/pawa/            ],
    '-p-a-w-a-'        => [ qw/w p a/           ],
    '-'                => [ qw//                ],
    '---'              => [ qw//                ],
    'A---Z'            => [ qw/Z A/             ],
    'ﾆｬ---'            => [ qw/ﾆｬ/              ],
    'ブック'           => [ qw/ブック/          ],
    'ワーク・ブック'   => [ qw/ワーク ブック/   ],
    'ワーク・・ブック' => [ qw/ワーク ブック/   ],
    '・・ヴェ・・'     => [ qw/ヴェ/            ],
    '世界タービン'     => [ qw/タービン 世界/   ],
    '謎の彼氏X'        => [ qw/彼氏 謎 X/       ],
    'ATH-EC7'          => [ qw/ATH EC/          ], # 7 is filterd
    '0x800ccc0f'       => [ qw/x8 c0 f cc/      ],
    '閉鎖空間'         => [ qw/空間/            ], # 閉鎖 is サ変
    '編集距離'         => [ qw/編集距離/        ],
    '編集・距離'       => [ qw/距離/            ],
    '原稿編集'         => [ qw/原稿/            ], # 編集 is ng_word
    '編集消去'         => [ qw//                ],
    '追加削除'         => [ qw//                ],
    '情報統合思念体'   => [ qw/情報/            ],
    '思念体'           => [ qw//                ],
    '大学　学会'       => [ qw/学会 大学/       ],
    '大学 学会'        => [ qw/学会 大学/       ],
    '東京-大阪'        => [ qw/大阪 東京/       ],
    '上-下'            => [ qw/上/              ],
    'さくらVPS'        => [ qw/VPS さくら/      ],
    'さくらのVPS'      => [ qw/VPS さくら/      ],
    'abra-kada-bra-oil' => [ qw/abra kada oil bra/ ],
    'ワーク・ブック・オブ・グレイセス' => [ qw/グレイセス オブ ワーク ブック/ ],
    ' ワーク ・ ブック ' => [ qw/ワーク ブック/ ],
    ' ワーク ・ブック '  => [ qw/ワーク ブック/ ],
    '心・技・体'         => [ qw/技 体 心/      ],
    'ウ・保'             => [ qw/保/            ],
    'ウ・まずい'         => [ qw//              ],
    '亜'                 => [ qw/亜/            ],
    'SOS団'              => [ qw/SOS/           ],
    '2010年'             => [ qw//              ],
    'ゴルゴ48'           => [ qw/ゴルゴ/        ],
    '三匹'               => [ qw//              ],
    '朝比奈さん'         => [ qw/朝比奈/        ],
    '図書委員会'         => [ qw/図書 委員会/   ],
    "図書\n委員会"       => [ qw/図書 委員会/   ],
    "図書 委員会"        => [ qw/図書 委員会/   ],
    "図書　委員会"       => [ qw/図書 委員会/   ],
    "SOS-48"             => [ qw/SOS/           ],
    "1・2・3"            => [ qw//              ],
);

my %concat1 = (
    '言語処理'         => [ qw/言語処理/        ],
    'p-model'          => [ qw/model p/         ],
    's+xx+yba'         => [ qw/yba xx s/        ],
    'p-'               => [ qw/p/               ],
    'p-p'              => [ qw/p/               ], # p is integrated. -> tf = 2
    'p-a'              => [ qw/p a/             ],
    '-pa'              => [ qw/pa/              ],
    '-pawa-'           => [ qw/pawa/            ],
    '-p-a-w-a-'        => [ qw/w p a/           ],
    '-'                => [ qw//                ],
    '---'              => [ qw//                ],
    'A---Z'            => [ qw/Z A/             ],
    'ﾆｬ---'            => [ qw/ﾆｬ/              ],
    'ブック'           => [ qw/ブック/          ],
    'ワーク・ブック'   => [ qw/ワーク ブック/   ],
    'ワーク・・ブック' => [ qw/ワーク ブック/   ],
    '・・ヴェ・・'     => [ qw/ヴェ/            ],
    '世界タービン'     => [ qw/世界タービン/    ],
    '謎の彼氏X'        => [ qw/彼氏X 謎/        ],
    'ATH-EC7'          => [ qw/ATH EC/          ], # 7 is filterd
    '0x800ccc0f'       => [ qw/ccc0 x8 f/       ],
    '閉鎖空間'         => [ qw/閉鎖空間/        ],
    '編集距離'         => [ qw/編集距離/        ],
    '編集・距離'       => [ qw/距離/            ],
    '原稿編集'         => [ qw/原稿/            ], # 編集 is ng_word
    '編集消去'         => [ qw//                ],
    '追加削除'         => [ qw//                ],
    '情報統合思念体'   => [ qw/思念体/          ],
    '思念体'           => [ qw/思念体/          ],
    '大学　学会'       => [ qw/学会 大学/       ],
    '大学 学会'        => [ qw/学会 大学/       ],
    '東京-大阪'        => [ qw/大阪 東京/       ],
    '上-下'            => [ qw/上/              ],
    'さくらVPS'        => [ qw/さくらVPS/       ],
    'さくらのVPS'      => [ qw/VPS さくら/      ],
    'abra-kada-bra-oil' => [ qw/abra kada oil bra/ ],
    'ワーク・ブック・オブ・グレイセス' => [ qw/グレイセス オブ ワーク ブック/ ],
    ' ワーク ・ ブック ' => [ qw/ワーク ブック/ ],
    ' ワーク ・ブック '  => [ qw/ワーク ブック/ ],
    '心・技・体'         => [ qw/技 体 心/      ],
    'ウ・保'             => [ qw/保/            ],
    'ウ・まずい'         => [ qw//              ],
    '亜'                 => [ qw/亜/            ],
    'SOS団'              => [ qw/SOS団/         ],
    '2010年'             => [ qw//              ],
    'ゴルゴ48'           => [ qw/ゴルゴ/        ],
    '三匹'               => [ qw//              ],
    '朝比奈さん'         => [ qw/朝比奈さん/    ],
    '図書委員会'         => [ qw/図書委員会/    ],
    "図書\n委員会"       => [ qw/図書 委員会/   ],
    "図書 委員会"        => [ qw/図書 委員会/   ],
    "図書　委員会"       => [ qw/図書 委員会/   ],
    "SOS-48"             => [ qw/SOS/           ],
    "1・2・3"            => [ qw//              ],
);

my %concat2 = (
    '言語処理'         => [ qw/言語処理/        ],
    'p-model'          => [ qw/p-model/         ],
    's+xx+yba'         => [ qw/yba xx s/        ],
    'p-'               => [ qw/p/               ],
    'p-p'              => [ qw/p-p/             ], # p is integrated. -> tf = 2
    'p-a'              => [ qw/p-a/             ],
    '-pa'              => [ qw/pa/              ],
    '-pawa-'           => [ qw/pawa/            ],
    '-p-a-w-a-'        => [ qw/w-a p-a/         ],
    '-'                => [ qw//                ],
    '---'              => [ qw//                ],
    'A---Z'            => [ qw/Z A/             ],
    'ﾆｬ---'            => [ qw/ﾆｬ/              ],
    'ブック'           => [ qw/ブック/          ],
    'ワーク・ブック'   => [ qw/ワーク・ブック/  ],
    'ワーク・・ブック' => [ qw/ワーク ブック/   ],
    '・・ヴェ・・'     => [ qw/ヴェ/            ],
    '世界タービン'     => [ qw/世界タービン/    ],
    '謎の彼氏X'        => [ qw/彼氏X 謎/        ],
    'ATH-EC7'          => [ qw/ATH-EC/          ], # 7 is filterd
    '0x800ccc0f'       => [ qw/ccc0f x8/        ],
    '閉鎖空間'         => [ qw/閉鎖空間/        ],
    '編集距離'         => [ qw/編集距離/        ],
    '編集・距離'       => [ qw/距離/            ],
    '原稿編集'         => [ qw/原稿/            ],
    '編集消去'         => [ qw//                ],
    '追加削除'         => [ qw//                ],
    '情報統合思念体'   => [ qw//                ],
    '思念体'           => [ qw/思念体/          ],
    '大学　学会'       => [ qw/学会 大学/       ],
    '大学 学会'        => [ qw/学会 大学/       ],
    '東京-大阪'        => [ qw/大阪 東京/       ],
    '上-下'            => [ qw/上/              ],
    'さくらVPS'        => [ qw/さくらVPS/       ],
    'さくらのVPS'      => [ qw/VPS さくら/      ],
    'abra-kada-bra-oil' => [ qw/bra-oil abra-kada/ ],
    'ワーク・ブック・オブ・グレイセス' => [ qw/オブ・グレイセス ワーク・ブック/ ],
    ' ワーク ・ ブック ' => [ qw/ワーク ブック/ ],
    ' ワーク ・ブック '  => [ qw/ワーク ブック/ ],
    '心・技・体'         => [ qw/技 体 心/      ],
    'ウ・保'             => [ qw/ウ・保/        ],
    'ウ・まずい'         => [ qw//              ],
    '亜'                 => [ qw/亜/            ],
    'SOS団'              => [ qw/SOS団/         ],
    '2010年'             => [ qw//              ],
    'ゴルゴ48'           => [ qw/ゴルゴ/        ],
    '三匹'               => [ qw//              ],
    '朝比奈さん'         => [ qw/朝比奈さん/    ],
    '図書委員会'         => [ qw/図書委員会/    ],
    "図書\n委員会"       => [ qw/図書 委員会/   ],
    "図書 委員会"        => [ qw/図書 委員会/   ],
    "図書　委員会"       => [ qw/図書 委員会/   ],
    "SOS-48"             => [ qw/SOS/           ],
    "1・2・3"            => [ qw//              ],
);

my %concat2_sahen_ok = (
    '言語処理'         => [ qw/言語処理/        ],
    'p-model'          => [ qw/p-model/         ],
    's+xx+yba'         => [ qw/yba xx s/        ],
    'p-'               => [ qw/p/               ],
    'p-p'              => [ qw/p-p/             ], # p is integrated. -> tf = 2
    'p-a'              => [ qw/p-a/             ],
    '-pa'              => [ qw/pa/              ],
    '-pawa-'           => [ qw/pawa/            ],
    '-p-a-w-a-'        => [ qw/w-a p-a/         ],
    '-'                => [ qw//                ],
    '---'              => [ qw//                ],
    'A---Z'            => [ qw/Z A/             ],
    'ﾆｬ---'            => [ qw/ﾆｬ/              ],
    'ブック'           => [ qw/ブック/          ],
    'ワーク・ブック'   => [ qw/ワーク・ブック/  ],
    'ワーク・・ブック' => [ qw/ワーク ブック/   ],
    '・・ヴェ・・'     => [ qw/ヴェ/            ],
    '世界タービン'     => [ qw/世界タービン/    ],
    '謎の彼氏X'        => [ qw/彼氏X 謎/        ],
    'ATH-EC7'          => [ qw/ATH-EC/          ], # 7 is filterd
    '0x800ccc0f'       => [ qw/ccc0f x8/        ],
    '閉鎖空間'         => [ qw/閉鎖空間/        ],
    '編集距離'         => [ qw/編集距離/        ],
    '編集・距離'       => [ qw/距離/            ],
    '原稿編集'         => [ qw/原稿/            ],
    '編集消去'         => [ qw//                ],
    '追加削除'         => [ qw/追加削除/        ],
    '情報統合思念体'   => [ qw/情報統合思念/    ],
    '思念体'           => [ qw/思念体/          ],
    '大学　学会'       => [ qw/学会 大学/       ],
    '大学 学会'        => [ qw/学会 大学/       ],
    '東京-大阪'        => [ qw/大阪 東京/       ],
    '上-下'            => [ qw/上/              ],
    'さくらVPS'        => [ qw/さくらVPS/       ],
    'さくらのVPS'      => [ qw/VPS さくら/      ],
    'abra-kada-bra-oil' => [ qw/bra-oil abra-kada/ ],
    'ワーク・ブック・オブ・グレイセス' => [ qw/オブ・グレイセス ワーク・ブック/ ],
    ' ワーク ・ ブック ' => [ qw/ワーク ブック/ ],
    ' ワーク ・ブック '  => [ qw/ワーク ブック/ ],
    '心・技・体'         => [ qw/技 体 心/      ],
    'ウ・保'             => [ qw/ウ・保/        ],
    'ウ・まずい'         => [ qw//              ],
    '亜'                 => [ qw/亜/            ],
    'SOS団'              => [ qw/SOS団/         ],
    '2010年'             => [ qw//              ],
    'ゴルゴ48'           => [ qw/ゴルゴ/        ],
    '三匹'               => [ qw//              ],
    '朝比奈さん'         => [ qw/朝比奈さん/    ],
    '図書委員会'         => [ qw/図書委員会/    ],
    "図書\n委員会"       => [ qw/図書 委員会/   ],
    "図書 委員会"        => [ qw/図書 委員会/   ],
    "図書　委員会"       => [ qw/図書 委員会/   ],
    "SOS-48"             => [ qw/SOS/           ],
    "1・2・3"            => [ qw//              ],
);

my %concat100 = (
    '言語処理'         => [ qw/言語処理/        ],
    'p-model'          => [ qw/p-model/         ],
    's+xx+yba'         => [ qw/yba xx s/        ],
    'p-'               => [ qw/p/               ],
    'p-p'              => [ qw/p-p/             ], # p is integrated. -> tf = 2
    'p-a'              => [ qw/p-a/             ],
    '-pa'              => [ qw/pa/              ],
    '-pawa-'           => [ qw/pawa/            ],
    '-p-a-w-a-'        => [ qw/p-a-w-a/         ],
    '-'                => [ qw//                ],
    '---'              => [ qw//                ],
    'A---Z'            => [ qw/Z A/             ],
    'ﾆｬ---'            => [ qw/ﾆｬ/              ],
    'ブック'           => [ qw/ブック/          ],
    'ワーク・ブック'   => [ qw/ワーク・ブック/  ],
    'ワーク・・ブック' => [ qw/ワーク ブック/   ],
    '・・ヴェ・・'     => [ qw/ヴェ/            ],
    '世界タービン'     => [ qw/世界タービン/    ],
    '謎の彼氏X'        => [ qw/彼氏X 謎/        ],
    'ATH-EC7'          => [ qw/ATH-EC/          ], # 7 is filterd
    '0x800ccc0f'       => [ qw/ccc0f x8/        ],
    '閉鎖空間'         => [ qw/閉鎖空間/        ],
    '編集距離'         => [ qw/編集距離/        ],
    '編集・距離'       => [ qw/距離/            ],
    '原稿編集'         => [ qw/原稿/            ],
    '編集消去'         => [ qw//                ],
    '追加削除'         => [ qw//                ],
    '情報統合思念体'   => [ qw/情報統合思念体/  ],
    '思念体'           => [ qw/思念体/          ],
    '大学　学会'       => [ qw/学会 大学/       ],
    '大学 学会'        => [ qw/学会 大学/       ],
    '東京-大阪'        => [ qw/大阪 東京/       ],
    '上-下'            => [ qw/上/              ],
    'さくらVPS'        => [ qw/さくらVPS/       ],
    'さくらのVPS'      => [ qw/VPS さくら/      ],
    'abra-kada-bra-oil' => [ qw/abra-kada-bra-oil/ ],
    'ワーク・ブック・オブ・グレイセス' => [ qw/ワーク・ブック・オブ・グレイセス/ ],
    'ルイズ・フランソワーズ・ル・ブラン・ド・ラ・ヴァリエール' => [ qw// ], # length 28 is filterd
    ' ワーク ・ ブック ' => [ qw/ワーク ブック/ ],
    ' ワーク ・ブック '  => [ qw/ワーク ブック/ ],
    '心・技・体'         => [ qw/技 体 心/      ],
    'ウ・保'             => [ qw/ウ・保/        ],
    'ウ・まずい'         => [ qw//              ],
    '亜'                 => [ qw/亜/            ],
    'SOS団'              => [ qw/SOS団/         ],
    '2010年'             => [ qw//              ],
    'ゴルゴ48'           => [ qw/ゴルゴ/        ],
    '三匹'               => [ qw//              ],
    '朝比奈さん'         => [ qw/朝比奈さん/    ],
    '図書委員会'         => [ qw/図書委員会/    ],
    "図書\n委員会"       => [ qw/図書 委員会/   ],
    "図書 委員会"        => [ qw/図書 委員会/   ],
    "図書　委員会"       => [ qw/図書 委員会/   ],
    "SOS-48"             => [ qw/SOS/           ],
    "1・2・3"            => [ qw//              ],
);

my %concat100_sahen_ok = (
    '言語処理'         => [ qw/言語処理/        ],
    'p-model'          => [ qw/p-model/         ],
    's+xx+yba'         => [ qw/yba xx s/        ],
    'p-'               => [ qw/p/               ],
    'p-p'              => [ qw/p-p/             ], # p is integrated. -> tf = 2
    'p-a'              => [ qw/p-a/             ],
    '-pa'              => [ qw/pa/              ],
    '-pawa-'           => [ qw/pawa/            ],
    '-p-a-w-a-'        => [ qw/p-a-w-a/         ],
    '-'                => [ qw//                ],
    '---'              => [ qw//                ],
    'A---Z'            => [ qw/Z A/             ],
    'ﾆｬ---'            => [ qw/ﾆｬ/              ],
    'ブック'           => [ qw/ブック/          ],
    'ワーク・ブック'   => [ qw/ワーク・ブック/  ],
    'ワーク・・ブック' => [ qw/ワーク ブック/   ],
    '・・ヴェ・・'     => [ qw/ヴェ/            ],
    '世界タービン'     => [ qw/世界タービン/    ],
    '謎の彼氏X'        => [ qw/彼氏X 謎/        ],
    'ATH-EC7'          => [ qw/ATH-EC/          ], # 7 is filterd
    '0x800ccc0f'       => [ qw/ccc0f x8/        ],
    '閉鎖空間'         => [ qw/閉鎖空間/        ],
    '編集距離'         => [ qw/編集距離/        ],
    '編集・距離'       => [ qw/距離/            ], # 編集 is ng word
    '原稿編集'         => [ qw/原稿/            ], # 編集 is ng word
    '編集消去'         => [ qw//                ], # 編集 and 消去 are ng words
    '追加削除'         => [ qw/追加削除/        ],
    '情報統合思念体'   => [ qw/情報統合思念体/  ],
    '思念体'           => [ qw/思念体/          ],
    '大学　学会'       => [ qw/学会 大学/       ],
    '大学 学会'        => [ qw/学会 大学/       ],
    '東京-大阪'        => [ qw/大阪 東京/       ],
    '上-下'            => [ qw/上/              ],
    'さくらVPS'        => [ qw/さくらVPS/       ],
    'さくらのVPS'      => [ qw/VPS さくら/      ],
    'abra-kada-bra-oil' => [ qw/abra-kada-bra-oil/ ],
    'ワーク・ブック・オブ・グレイセス' => [ qw/ワーク・ブック・オブ・グレイセス/ ],
    'ルイズ・フランソワーズ・ル・ブラン・ド・ラ・ヴァリエール' => [ qw// ], # length 28 is filterd
    ' ワーク ・ ブック ' => [ qw/ワーク ブック/ ],
    ' ワーク ・ブック '  => [ qw/ワーク ブック/ ],
    '心・技・体'         => [ qw/技 体 心/      ],
    'ウ・保'             => [ qw/ウ・保/        ],
    'ウ・まずい'         => [ qw//              ],
    '亜'                 => [ qw/亜/            ],
    'SOS団'              => [ qw/SOS団/         ],
    '2010年'             => [ qw//              ],
    'ゴルゴ48'           => [ qw/ゴルゴ/        ],
    '三匹'               => [ qw//              ],
    '朝比奈さん'         => [ qw/朝比奈さん/    ],
    '図書委員会'         => [ qw/図書委員会/    ],
    "図書\n委員会"       => [ qw/図書 委員会/   ],
    "図書 委員会"        => [ qw/図書 委員会/   ],
    "図書　委員会"       => [ qw/図書 委員会/   ],
    "SOS-48"             => [ qw/SOS/           ],
    "1・2・3"            => [ qw//              ],
);

my %concat100_term_length_min2 = (
    '言語処理'         => [ qw/言語処理/        ],
    'p-model'          => [ qw/p-model/         ],
    's+xx+yba'         => [ qw/yba xx/          ],
    'p-'               => [ qw//                ],
    'p-p'              => [ qw/p-p/             ], # p is integrated. -> tf = 2
    'p-a'              => [ qw/p-a/             ],
    '-pa'              => [ qw/pa/              ],
    '-pawa-'           => [ qw/pawa/            ],
    '-p-a-w-a-'        => [ qw/p-a-w-a/         ],
    '-'                => [ qw//                ],
    '---'              => [ qw//                ],
    'A---Z'            => [ qw//                ],
    'ﾆｬ---'            => [ qw/ﾆｬ/              ],
    'ブック'           => [ qw/ブック/          ],
    'ワーク・ブック'   => [ qw/ワーク・ブック/  ],
    'ワーク・・ブック' => [ qw/ワーク ブック/   ],
    '・・ヴェ・・'     => [ qw/ヴェ/            ],
    '世界タービン'     => [ qw/世界タービン/    ],
    '謎の彼氏X'        => [ qw/彼氏X/           ],
    'ATH-EC7'          => [ qw/ATH-EC/          ], # 7 is filterd
    '0x800ccc0f'       => [ qw/ccc0f x8/        ],
    '閉鎖空間'         => [ qw/閉鎖空間/        ],
    '編集距離'         => [ qw/編集距離/        ],
    '編集・距離'       => [ qw/距離/            ],
    '原稿編集'         => [ qw/原稿/            ],
    '編集消去'         => [ qw//                ],
    '追加削除'         => [ qw//                ],
    '情報統合思念体'   => [ qw/情報統合思念体/  ],
    '思念体'           => [ qw/思念体/          ],
    '大学　学会'       => [ qw/学会 大学/       ],
    '大学 学会'        => [ qw/学会 大学/       ],
    '東京-大阪'        => [ qw/大阪 東京/       ],
    '上-下'            => [ qw//                ],
    'さくらVPS'        => [ qw/さくらVPS/       ],
    'さくらのVPS'      => [ qw/VPS さくら/      ],
    'abra-kada-bra-oil' => [ qw/abra-kada-bra-oil/ ],
    'ワーク・ブック・オブ・グレイセス' => [ qw/ワーク・ブック・オブ・グレイセス/ ],
    'ルイズ・フランソワーズ・ル・ブラン・ド・ラ・ヴァリエール' => [ qw// ], # length 28 is filterd
    ' ワーク ・ ブック ' => [ qw/ワーク ブック/ ],
    ' ワーク ・ブック '  => [ qw/ワーク ブック/ ],
    '心・技・体'         => [ qw//              ],
    'ウ・保'             => [ qw/ウ・保/        ],
    'ウ・まずい'         => [ qw//              ],
    '亜'                 => [ qw//              ],
    'SOS団'              => [ qw/SOS団/         ],
    '2010年'             => [ qw//              ],
    'ゴルゴ48'           => [ qw/ゴルゴ/        ],
    '三匹'               => [ qw//              ],
    '朝比奈さん'         => [ qw/朝比奈さん/    ],
    '図書委員会'         => [ qw/図書委員会/    ],
    "図書\n委員会"       => [ qw/図書 委員会/   ],
    "図書 委員会"        => [ qw/図書 委員会/   ],
    "図書　委員会"       => [ qw/図書 委員会/   ],
    "SOS-48"             => [ qw/SOS/           ],
    "1・2・3"            => [ qw//              ],
);

my %concat100_term_length_min4 = (
    '言語処理'         => [ qw/言語処理/        ],
    'p-model'          => [ qw/p-model/         ],
    's+xx+yba'         => [ qw//                ],
    'p-'               => [ qw//                ],
    'p-p'              => [ qw//                ], # p is integrated. -> tf = 2
    'p-a'              => [ qw//                ],
    '-pa'              => [ qw//                ],
    '-pawa-'           => [ qw/pawa/            ],
    '-p-a-w-a-'        => [ qw/p-a-w-a/         ],
    '-'                => [ qw//                ],
    '---'              => [ qw//                ],
    'A---Z'            => [ qw//                ],
    'ﾆｬ---'            => [ qw//                ],
    'ブック'           => [ qw//                ],
    'ワーク・ブック'   => [ qw/ワーク・ブック/  ],
    'ワーク・・ブック' => [ qw//                ],
    '・・ヴェ・・'     => [ qw//                ],
    '世界タービン'     => [ qw/世界タービン/    ],
    '謎の彼氏X'        => [ qw//                ],
    'ATH-EC7'          => [ qw/ATH-EC/          ], # 7 is filterd
    '0x800ccc0f'       => [ qw/ccc0f/           ],
    '閉鎖空間'         => [ qw/閉鎖空間/        ],
    '編集距離'         => [ qw/編集距離/        ],
    '編集・距離'       => [ qw//                ],
    '原稿編集'         => [ qw//                ],
    '編集消去'         => [ qw//                ],
    '追加削除'         => [ qw//                ],
    '情報統合思念体'   => [ qw/情報統合思念体/  ],
    '思念体'           => [ qw//                ],
    '大学　学会'       => [ qw//                ],
    '大学 学会'        => [ qw//                ],
    '東京-大阪'        => [ qw//                ],
    '上-下'            => [ qw//                ],
    'さくらVPS'        => [ qw/さくらVPS/       ],
    'さくらのVPS'      => [ qw//                ],
    'abra-kada-bra-oil' => [ qw/abra-kada-bra-oil/ ],
    'ワーク・ブック・オブ・グレイセス' => [ qw/ワーク・ブック・オブ・グレイセス/ ],
    'ルイズ・フランソワーズ・ル・ブラン・ド・ラ・ヴァリエール' => [ qw// ], # length 28 is filterd
    ' ワーク ・ ブック ' => [ qw//              ],
    ' ワーク ・ブック '  => [ qw//              ],
    '心・技・体'         => [ qw//              ],
    'ウ・保'             => [ qw//              ],
    'ウ・まずい'         => [ qw//              ],
    '亜'                 => [ qw//              ],
    'SOS団'              => [ qw/SOS団/         ],
    '2010年'             => [ qw//              ],
    'ゴルゴ48'           => [ qw//              ],
    '三匹'               => [ qw//              ],
    '朝比奈さん'         => [ qw/朝比奈さん/    ],
    '図書委員会'         => [ qw/図書委員会/    ],
    "図書\n委員会"       => [ qw//              ],
    "図書 委員会"        => [ qw//              ],
    "図書　委員会"       => [ qw//              ],
    "SOS-48"             => [ qw//              ],
    "1・2・3"            => [ qw//              ],
);

my %concat100_term_length_min2_max6 = (
    '言語処理'         => [ qw/言語処理/        ],
    'p-model'          => [ qw//                ],
    's+xx+yba'         => [ qw/yba xx/          ],
    'p-'               => [ qw//                ],
    'p-p'              => [ qw/p-p/             ], # p is integrated. -> tf = 2
    'p-a'              => [ qw/p-a/             ],
    '-pa'              => [ qw/pa/              ],
    '-pawa-'           => [ qw/pawa/            ],
    '-p-a-w-a-'        => [ qw//                ],
    '-'                => [ qw//                ],
    '---'              => [ qw//                ],
    'A---Z'            => [ qw//                ],
    'ﾆｬ---'            => [ qw/ﾆｬ/              ],
    'ブック'           => [ qw/ブック/          ],
    'ワーク・ブック'   => [ qw//                ],
    'ワーク・・ブック' => [ qw/ワーク ブック/   ],
    '・・ヴェ・・'     => [ qw/ヴェ/            ],
    '世界タービン'     => [ qw/世界タービン/    ],
    '謎の彼氏X'        => [ qw/彼氏X/           ],
    'ATH-EC7'          => [ qw/ATH-EC/          ], # 7 is filterd
    '0x800ccc0f'       => [ qw/ccc0f x8/        ],
    '閉鎖空間'         => [ qw/閉鎖空間/        ],
    '編集距離'         => [ qw/編集距離/        ],
    '編集・距離'       => [ qw/距離/            ],
    '原稿編集'         => [ qw/原稿/            ],
    '編集消去'         => [ qw//                ],
    '追加削除'         => [ qw//                ],
    '情報統合思念体'   => [ qw//                ],
    '思念体'           => [ qw/思念体/          ],
    '大学　学会'       => [ qw/学会 大学/       ],
    '大学 学会'        => [ qw/学会 大学/       ],
    '東京-大阪'        => [ qw/大阪 東京/       ],
    '上-下'            => [ qw//                ],
    'さくらVPS'        => [ qw/さくらVPS/       ],
    'さくらのVPS'      => [ qw/VPS さくら/      ],
    'abra-kada-bra-oil' => [ qw//               ],
    'ワーク・ブック・オブ・グレイセス' => [ qw// ],
    'ルイズ・フランソワーズ・ル・ブラン・ド・ラ・ヴァリエール' => [ qw// ], # length 28 is filterd
    ' ワーク ・ ブック ' => [ qw/ワーク ブック/ ],
    ' ワーク ・ブック '  => [ qw/ワーク ブック/ ],
    '心・技・体'         => [ qw//              ],
    'ウ・保'             => [ qw/ウ・保/        ],
    'ウ・まずい'         => [ qw//              ],
    '亜'                 => [ qw//              ],
    'SOS団'              => [ qw/SOS団/         ],
    '2010年'             => [ qw//              ],
    'ゴルゴ48'           => [ qw/ゴルゴ/        ],
    '三匹'               => [ qw//              ],
    '朝比奈さん'         => [ qw/朝比奈さん/    ],
    '図書委員会'         => [ qw/図書委員会/    ],
    "図書\n委員会"       => [ qw/図書 委員会/   ],
    "図書 委員会"        => [ qw/図書 委員会/   ],
    "図書　委員会"       => [ qw/図書 委員会/   ],
    "SOS-48"             => [ qw/SOS/           ],
    "1・2・3"            => [ qw//              ],
);

my %concat1_num_ok = (
    'ATH-EC7',    => [ qw/EC7 ATH/      ],
    '0x800ccc0f'  => [ qw/00cc c0f 0x8/ ],
    '2010年'      => [ qw/2010年/       ],
    'ゴルゴ48'    => [ qw/ゴルゴ48/     ],
    '三匹'        => [ qw/三匹/         ],
    "SOS-48"      => [ qw/SOS/          ],
    "1・2・3"     => [ qw//             ],
);

my %concat2_num_ok = (
    'ATH-EC7',    => [ qw/ATH-EC/      ], # only '7' is not allowed
    '0x800ccc0f'  => [ qw/0x800 ccc0f/ ],
    '2010年'      => [ qw/2010年/      ],
    'ゴルゴ48'    => [ qw/ゴルゴ48/    ],
    '三匹'        => [ qw/三匹/        ],
    "SOS-48"      => [ qw/SOS-48/      ],
    "1・2・3"     => [ qw//            ],
);

my %concat100_num_ok = (
    'ATH-EC7',    => [ qw/ATH-EC7/    ],
    '0x800ccc0f'  => [ qw/0x800ccc0f/ ],
    '2010年'      => [ qw/2010年/     ],
    'ゴルゴ48'    => [ qw/ゴルゴ48/   ],
    '三匹'        => [ qw/三匹/       ],
    "SOS-48"      => [ qw/SOS-48/     ],
    "1・2・3"     => [ qw//           ],
);

subtest 'concat: 0' => sub {

    binmode Test::More->builder->$_ => ':utf8'
        for qw/output failure_output todo_output/;

    my $tfidf = Lingua::JA::TFWebIDF->new(\%config);

    for my $key (keys %concat0)
    {
        my @terms = fetch_term($tfidf->tfidf($key)->list);

        is_deeply(\@terms, $concat0{$key}, "bag of words of $key");
    }
};

subtest 'concat: 0, 接尾: ng' => sub {

    binmode Test::More->builder->$_ => ':utf8'
    for qw/output failure_output todo_output/;

    $config{pos1_filter} = [qw/非自立 代名詞 数 ナイ形容詞語幹 副詞可能 サ変接続 接尾/],
    $config{concat_max}  = 0;
    my $tfidf = Lingua::JA::TFWebIDF->new(\%config);

    for my $key (keys %concat0_suffix_ng)
    {
        my @terms = fetch_term($tfidf->tfidf($key)->list);

        is_deeply(\@terms, $concat0_suffix_ng{$key}, "bag of words of $key");
    }
};

subtest 'concat: 1' => sub {

    binmode Test::More->builder->$_ => ':utf8'
        for qw/output failure_output todo_output/;

    $config{pos1_filter} = [qw/非自立 代名詞 数 ナイ形容詞語幹 副詞可能 サ変接続/],
    $config{concat_max}  = 1;
    my $tfidf = Lingua::JA::TFWebIDF->new(\%config);

    for my $key (keys %concat1)
    {
        my @terms = fetch_term($tfidf->tfidf($key)->list);

        is_deeply(\@terms, $concat1{$key}, "bag of words of $key");
    }
};

subtest 'concat: 1, num: ok' => sub {

    binmode Test::More->builder->$_ => ':utf8'
        for qw/output failure_output todo_output/;

    $config{pos1_filter} = [qw/非自立 代名詞 ナイ形容詞語幹 副詞可能 サ変接続/],
    $config{concat_max}  = 1;
    my $tfidf = Lingua::JA::TFWebIDF->new(\%config);

    for my $key (keys %concat1_num_ok)
    {
        my @terms = fetch_term($tfidf->tfidf($key)->list);

        is_deeply(\@terms, $concat1_num_ok{$key}, "bag of words of $key");
    }
};

subtest 'concat: 2' => sub {

    binmode Test::More->builder->$_ => ':utf8'
        for qw/output failure_output todo_output/;

    $config{pos1_filter} = [qw/非自立 代名詞 数 ナイ形容詞語幹 副詞可能 サ変接続/],
    $config{concat_max}  = 2;
    my $tfidf = Lingua::JA::TFWebIDF->new(\%config);

    for my $key (keys %concat2)
    {
        my @terms = fetch_term($tfidf->tfidf($key)->list);

        is_deeply(\@terms, $concat2{$key}, "bag of words of $key");
    }
};

subtest 'concat: 2, num: ok' => sub {

    binmode Test::More->builder->$_ => ':utf8'
        for qw/output failure_output todo_output/;

    $config{pos1_filter} = [qw/非自立 代名詞 ナイ形容詞語幹 副詞可能 サ変接続/],
    $config{concat_max}  = 2;
    my $tfidf = Lingua::JA::TFWebIDF->new(\%config);

    for my $key (keys %concat2_num_ok)
    {
        my @terms = fetch_term($tfidf->tfidf($key)->list);

        is_deeply(\@terms, $concat2_num_ok{$key}, "bag of words of $key");
    }
};

subtest 'concat: 2, サ変: ok' => sub {

    binmode Test::More->builder->$_ => ':utf8'
    for qw/output failure_output todo_output/;

    $config{pos1_filter} = [qw/非自立 代名詞 数 ナイ形容詞語幹 副詞可能/],
    $config{concat_max}  = 2;
    my $tfidf = Lingua::JA::TFWebIDF->new(\%config);

    for my $key (keys %concat2_sahen_ok)
    {
        my @terms = fetch_term($tfidf->tfidf($key)->list);

        is_deeply(\@terms, $concat2_sahen_ok{$key}, "bag of words of $key");
    }
};

subtest 'concat: 100' => sub {

    binmode Test::More->builder->$_ => ':utf8'
        for qw/output failure_output todo_output/;

    $config{pos1_filter} = [qw/非自立 代名詞 数 ナイ形容詞語幹 副詞可能 サ変接続/],
    $config{concat_max}  = 100;
    my $tfidf = Lingua::JA::TFWebIDF->new(\%config);

    for my $key (keys %concat100)
    {
        my @terms = fetch_term($tfidf->tfidf($key)->list);

        is_deeply(\@terms, $concat100{$key}, "bag of words of $key");
    }
};

subtest 'concat: 100, num: ok' => sub {

    binmode Test::More->builder->$_ => ':utf8'
        for qw/output failure_output todo_output/;

    $config{pos1_filter} = [qw/非自立 代名詞 ナイ形容詞語幹 副詞可能 サ変接続/],
    $config{concat_max}  = 100;
    my $tfidf = Lingua::JA::TFWebIDF->new(\%config);

    for my $key (keys %concat100_num_ok)
    {
        my @terms = fetch_term($tfidf->tfidf($key)->list);

        is_deeply(\@terms, $concat100_num_ok{$key}, "bag of words of $key");
    }
};

subtest 'concat: 100, サ変接続: ok' => sub {

    binmode Test::More->builder->$_ => ':utf8'
    for qw/output failure_output todo_output/;

    $config{pos1_filter} = [qw/非自立 代名詞 数 ナイ形容詞語幹 副詞可能/],
    $config{concat_max}  = 100;
    my $tfidf = Lingua::JA::TFWebIDF->new(\%config);

    for my $key (keys %concat100_sahen_ok)
    {
        my @terms = fetch_term($tfidf->tfidf($key)->list);

        is_deeply(\@terms, $concat100_sahen_ok{$key}, "bag of words of $key");
    }
};

subtest 'concat: 100, term_length_min: 2' => sub {

    binmode Test::More->builder->$_ => ':utf8'
        for qw/output failure_output todo_output/;

    $config{pos1_filter} = [qw/非自立 代名詞 数 ナイ形容詞語幹 副詞可能 サ変接続/],
    $config{concat_max}  = 100;
    $config{term_length_min} = 2;
    my $tfidf = Lingua::JA::TFWebIDF->new(\%config);

    for my $key (keys %concat100_term_length_min2)
    {
        my @terms = fetch_term($tfidf->tfidf($key)->list);

        is_deeply(\@terms, $concat100_term_length_min2{$key}, "bag of words of $key");
    }
};

subtest 'concat: 100, term_length_min: 4' => sub {

    binmode Test::More->builder->$_ => ':utf8'
        for qw/output failure_output todo_output/;

    $config{pos1_filter} = [qw/非自立 代名詞 数 ナイ形容詞語幹 副詞可能 サ変接続/],
    $config{concat_max}  = 100;
    $config{term_length_min} = 4;
    my $tfidf = Lingua::JA::TFWebIDF->new(\%config);

    for my $key (keys %concat100_term_length_min4)
    {
        my @terms = fetch_term($tfidf->tfidf($key)->list);

        is_deeply(\@terms, $concat100_term_length_min4{$key}, "bag of words of $key");
    }
};

subtest 'concat: 100, term_length_min: 2, term_length_max: 6' => sub {

    binmode Test::More->builder->$_ => ':utf8'
        for qw/output failure_output todo_output/;

    $config{pos1_filter} = [qw/非自立 代名詞 数 ナイ形容詞語幹 副詞可能 サ変接続/],
    $config{concat_max}  = 100;
    $config{term_length_min} = 2;
    $config{term_length_max} = 6;
    my $tfidf = Lingua::JA::TFWebIDF->new(\%config);

    for my $key (keys %concat100_term_length_min2_max6)
    {
        my @terms = fetch_term($tfidf->tfidf($key)->list);

        is_deeply(\@terms, $concat100_term_length_min2_max6{$key}, "bag of words of $key");
    }
};

done_testing;


sub fetch_term
{
    my $results = shift;

    my @terms;

    for my $result (@{$results})
    {
        my ($word, $score) = each %{$result};

        push(@terms, $word);
    }

    return @terms;
}
