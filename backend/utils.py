# -*- coding: utf-8 -*-

__author__ = 'Tim Süberkrüb'

import datetime
import hangups


def get_conv_icon(conv):
    icon_url = ""
    if len(conv.users) <= 2:
        for user in conv.users:
            if not user.is_self and user.photo_url:
                icon_url = "https:" + user.photo_url
                break
            elif not user.is_self:
                icon_url = "unknown/contact"
    else:
        icon_url = "unknown/group"
    return icon_url


def get_message_html(segments):
    html = ""
    for segment in segments:
        text = "{0}"
        if segment.link_target is not None:
            text = '<a href="' + str(segment.link_target) + '">{0}</a>'
        elif segment.is_bold:
            text = '<b>{0}</b>'
        elif segment.is_italic:
            text = '<i>{0}</i>'
        elif segment.is_strikethrough:
            text = '<s>{0}</s>'
        elif segment.is_underline:
            text = '<u>{0}</u>'
        html += text.format(segment.text)
    return html


def get_message_timestr(timestamp):
    now = datetime.datetime.now()
    f = "%H:%M"
    if (now.year != timestamp.year):
        f = "%Y " + f
    if (now.isocalendar()[1] != timestamp.isocalendar()[1]):
        f = "%d. %b " + f
    elif now.day != timestamp.day:
        f = "%a, " + f
    timestr = timestamp.strftime(f)
    return timestr


def get_unread_messages_count(conv):
    num_unread = len([conv_event for conv_event in conv.unread_events if
                      isinstance(conv_event, hangups.ChatMessageEvent) and
                      not conv.get_user(conv_event.user_id).is_self])
    return num_unread