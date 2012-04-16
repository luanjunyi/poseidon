from sdk import qqweibo as qq_sdk
from sdk import weibopy as sina_sdk

method_dict = {'public_timeline':
                   {"name": {"sina": sina_sdk.API.public_timeline,
                             "qq": qq_sdk.API._statuses_public_timeline},
                    "arg_convert": {},
                    "ret_convert": {"sina": {"text": "text"},
                                    "qq": {"text": "text"},}
                   },

                'home_timeline':
                    {"name": {"sina": sina_sdk.API.friends_timeline,
                              "qq": qq_sdk.API._statuses_home_timeline}, 
                     "arg_convert": {}, 
                     "ret_convert": {"sina": {"text": "text"},
                                     "qq": {"text": "text"}},
                    },

                'user_timeline':
                    {"name": {"sina": sina_sdk.API.user_timeline,
                              "qq": qq_sdk.API._statuses_user_timeline},
                     "arg_convert": {"sina": {"uid": "user_id"},
                                     "qq": {"uid": "name"}},
                     "ret_convert": {"sina": {"text": "text"},
                                     "qq": {"text": "text"}}
                    },
                

                'update_status':
                   {"name": {"sina": sina_sdk.API.update_status,
                             "qq": qq_sdk.API._t_add},
                    "arg_convert": {"sina": {"text": "status"},
                                    "qq": {'text': "content"}},
                    "ret_convert": {"sina": {"message": "text"},
                                    "qq": {"message": "id"}}
                   },

                'comment':
                    {"name": {"sina": sina_sdk.API.comment,
                              "qq": qq_sdk.API._t_comment},
                     "arg_convert": {"sina": {"id": "id",
                                              "text": "comment",
                                              "cid": "cid"},
                                     "qq": {"id": "reid",
                                            "text": "content"}},
                     "ret_convert": {"sina": {"message": "text"},
                                     "qq": {"message": "id"}}
                    },

                'get_status':
                    {"name": {"sina": sina_sdk.API.get_status,
                              "qq": qq_sdk.API._t_show},
                     "arg_convert": {"sina": {"id": "id"},
                                     "qq": {"id": "id"}},
                     "ret_convert": {"sina": {"text": "text"},
                                     "qq": {"text": "text"}}
                    },

                'post_image_text':
                    {"name": {"sina": sina_sdk.API.upload,
                              "qq": qq_sdk.API._t_add_pic},
                     "arg_convert": {"sina": {"text": "status",
                                              "image": "filename"},
                                     "qq": {"text": "content",
                                            "image": "filename"}},
                     "ret_convert": {"sina": {"message": "text"},
                                     "qq": {"message": "id"}}
                    },

                'retweet':
                    {"name": {"sina": sina_sdk.API.repost,
                              "qq": qq_sdk.API._t_re_add},
                     "arg_convert": {"sina": {"id": "id",
                                              "text": "status"},
                                     "qq": {"id": "reid",
                                            "text": "content"}},
                     "ret_convert": {"sina": {"message": "text"},
                                     "qq": {"message": "id"}}
                     },

                'get_user':
                    {"name": {"sina": sina_sdk.API.get_user,
                              "qq": qq_sdk.API._user_other_info},
                     "arg_convert": {"sina": {"uid": "user_id"},
                                     "qq": {"uid": "name"}},
                     "ret_convert": {"sina": {"screen_name": "screen_name"},
                                     "qq": {"screen_name": "name"}}
                    },

                'search_users':
                    {"name": {"sina": sina_sdk.API.search_users,
                              "qq": qq_sdk.API._search_user},
                     "arg_convert": {"sina": {"keyword": "q"},
                                     "qq": {"keyword": "keyword"}},
                     "ret_convert": {"sina": {"screen_name": "name"},
                                     "qq": {"screen_name": "name"}}
                    },
                    
                'following':
                    {"name": {"sina": sina_sdk.API.friends,
                              "qq": qq_sdk.API._friends_user_idollist},
                     "arg_convert": {"sina": {"uid": "user_id"},
                                     "qq": {"uid": "name"}},
                     "ret_convert": {"sina": {"screen_name": "name"},
                                     "qq": {"screen_name": "name"}}
                     },
                
                'follower':
                    {"name": {"sina": sina_sdk.API.followers,
                              "qq": qq_sdk.API._friends_user_fanslist},
                     "arg_convert": {"sina": {"uid": "user_id"},
                                     "qq": {"uid": "name"}},
                     "ret_convert": {"sina": {"screen_name": "name"},
                                     "qq": {"screen_name": "name"}}
                    },

                'follow':
                    {"name": {"sina": sina_sdk.API.create_friendship,
                              "qq": qq_sdk.API._friends_add},
                     "arg_convert": {"sina": {"uid": "user_id"},
                                     "qq": {"uid": "name"}},
                     "ret_convert": {"sina": {"message": "screen_name"},
                                     "qq": {"message": "msg"}}
                    },
                
                'unfollow':
                    {"name": {"sina": sina_sdk.API.destroy_friendship,
                              "qq": qq_sdk.API._friends_del},
                     "arg_convert": {"sina": {"uid": "user_id"},
                                     "qq": {"uid": "name"}},
                     "ret_convert": {"sina": {"message": "screen_name"},
                                     "qq": {"message": "msg"}}
                    },

                'is_user_following_me':
                    {"name": {"sina": sina_sdk.API.exists_friendship,
                              "qq": qq_sdk.API.is_user_following_me},
                     "arg_convert": {"sina": {"user_uid": "user_a",
                                              "my_uid": "user_b"},
                                     "qq": {"user_uid": "user"}},
                     "ret_convert": {"sina": {"friends": "friends"},
                                     "qq": {}}
                    },
                    
                'is_following_user':
                    {"name": {"sina": sina_sdk.API.exists_friendship,
                              "qq": qq_sdk.API.is_following_user},
                     "arg_convert": {"sina": {"user_uid": "user_b",
                                              "my_uid": "user_a"},
                                     "qq": {"user_uid": "user"}},
                     "ret_convert": {"sina": {"friends": "friends"},
                                     "qq": {}}
                    },

                'update_profile':
                    {"name": {"sina": sina_sdk.API.update_profile,
                              "qq": qq_sdk.API._user_update},
                     "arg_convert": {"sina": {"screen_name": "name",
                                              "description": "description"},
                                     "qq": {"screen_name": "nick",
                                            "description": "introduction"}},
                    "ret_convert": {"sina": {"message": "screen_name"},
                                    "qq": {"message": "msg"}}
                    },

                'update_profile_image': 
                    {"name": {"sina": sina_sdk.API.update_profile_image,
                              "qq": qq_sdk.API._user_update_head},
                     "arg_convert": {"sina": {"image": "filename"},
                                     "qq": {"image": "filename"}},
                     "ret_convert": {"sina": {"message": "screen_name"},
                                     "qq": {"message": "msg"}}
                    },

                'me':
                    {"name": {"sina": sina_sdk.API.me,
                              "qq": qq_sdk.API.me},
                    "arg_convert": {},
                    "ret_convert": {"sina": {"name": "screen_name"},
                                    "qq": {"name": "name"}}
                    }
               }
