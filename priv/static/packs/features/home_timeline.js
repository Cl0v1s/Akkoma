(window.webpackJsonp=window.webpackJsonp||[]).push([[33],{755:function(e,t,n){"use strict";n.r(t);var o,i,a=n(0),c=n(2),s=n(7),l=n(1),r=n(3),u=n.n(r),h=n(12),d=n(35),m=n(977),p=n(669),b=n(665),f=n(245),g=n(6),O=n(1023),j=Object(g.g)(o=function(e){function t(){return e.apply(this,arguments)||this}return Object(s.a)(t,e),t.prototype.render=function(){var e=this.props,t=e.settings,n=e.onChange;return Object(a.a)("div",{},void 0,Object(a.a)("span",{className:"column-settings__section"},void 0,Object(a.a)(g.b,{id:"home.column_settings.basic",defaultMessage:"Basic"})),Object(a.a)("div",{className:"column-settings__row"},void 0,Object(a.a)(O.a,{prefix:"home_timeline",settings:t,settingPath:["shows","reblog"],onChange:n,label:Object(a.a)(g.b,{id:"home.column_settings.show_reblogs",defaultMessage:"Show boosts"})})),Object(a.a)("div",{className:"column-settings__row"},void 0,Object(a.a)(O.a,{prefix:"home_timeline",settings:t,settingPath:["shows","reply"],onChange:n,label:Object(a.a)(g.b,{id:"home.column_settings.show_replies",defaultMessage:"Show replies"})})))},t}(u.a.PureComponent))||o,v=n(72),_=Object(h.connect)(function(e){return{settings:e.getIn(["settings","home"])}},function(e){return{onChange:function(t,n){e(Object(v.c)(["home"].concat(t),n))},onSave:function(){e(Object(v.d)())}}})(j),M=n(310);n.d(t,"default",function(){return P});var w=Object(g.f)({title:{id:"column.home",defaultMessage:"Home"}}),P=Object(h.connect)(function(e){return{hasUnread:e.getIn(["timelines","home","unread"])>0,isPartial:e.getIn(["timelines","home","isPartial"])}})(i=Object(g.g)(i=function(e){function t(){for(var t,n=arguments.length,o=new Array(n),i=0;i<n;i++)o[i]=arguments[i];return t=e.call.apply(e,[this].concat(o))||this,Object(l.a)(Object(c.a)(t),"handlePin",function(){var e=t.props,n=e.columnId,o=e.dispatch;o(n?Object(f.h)(n):Object(f.e)("HOME",{}))}),Object(l.a)(Object(c.a)(t),"handleMove",function(e){var n=t.props,o=n.columnId;(0,n.dispatch)(Object(f.g)(o,e))}),Object(l.a)(Object(c.a)(t),"handleHeaderClick",function(){t.column.scrollTop()}),Object(l.a)(Object(c.a)(t),"setRef",function(e){t.column=e}),Object(l.a)(Object(c.a)(t),"handleLoadMore",function(e){t.props.dispatch(Object(d.t)({maxId:e}))}),t}Object(s.a)(t,e);var n=t.prototype;return n.componentDidMount=function(){this._checkIfReloadNeeded(!1,this.props.isPartial)},n.componentDidUpdate=function(e){this._checkIfReloadNeeded(e.isPartial,this.props.isPartial)},n.componentWillUnmount=function(){this._stopPolling()},n._checkIfReloadNeeded=function(e,t){var n=this.props.dispatch;e!==t&&(!e&&t?this.polling=setInterval(function(){n(Object(d.t)())},3e3):e&&!t&&this._stopPolling())},n._stopPolling=function(){this.polling&&(clearInterval(this.polling),this.polling=null)},n.render=function(){var e=this.props,t=e.intl,n=e.shouldUpdateScroll,o=e.hasUnread,i=e.columnId,c=e.multiColumn,s=!!i;return u.a.createElement(p.a,{bindToDocument:!c,ref:this.setRef,label:t.formatMessage(w.title)},Object(a.a)(b.a,{icon:"home",active:o,title:t.formatMessage(w.title),onPin:this.handlePin,onMove:this.handleMove,onClick:this.handleHeaderClick,pinned:s,multiColumn:c},void 0,Object(a.a)(_,{})),Object(a.a)(m.a,{trackScroll:!s,scrollKey:"home_timeline-"+i,onLoadMore:this.handleLoadMore,timelineId:"home",emptyMessage:Object(a.a)(g.b,{id:"empty_column.home",defaultMessage:"Your home timeline is empty! Visit {public} or use search to get started and meet other users.",values:{public:Object(a.a)(M.a,{to:"/timelines/public"},void 0,Object(a.a)(g.b,{id:"empty_column.home.public_timeline",defaultMessage:"the public timeline"}))}}),shouldUpdateScroll:n,bindToDocument:!c}))},t}(u.a.PureComponent))||i)||i}}]);
//# sourceMappingURL=home_timeline.js.map