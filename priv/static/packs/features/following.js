(window.webpackJsonp=window.webpackJsonp||[]).push([[28],{821:function(a,t,o){"use strict";o.r(t),o.d(t,"default",(function(){return _}));var c,e,n,s=o(0),r=o(2),i=(o(9),o(6),o(8)),p=o(1),u=o(65),d=o.n(u),l=(o(3),o(15)),b=o(21),h=o(5),m=o.n(h),f=o(16),j=o.n(f),I=o(306),O=o(26),y=o(7),v=o(1053),w=o(757),g=o(1084),M=o(764),k=o(1049),A=o(1057);var _=Object(l.connect)((function(a,t){return{isAccount:!!a.getIn(["accounts",t.params.accountId]),accountIds:a.getIn(["user_lists","following",t.params.accountId,"items"]),hasMore:!!a.getIn(["user_lists","following",t.params.accountId,"next"]),blockedBy:a.getIn(["relationships",t.params.accountId,"blocked_by"],!1)}}))((n=e=function(a){Object(i.a)(o,a);var t;t=o;function o(){for(var t,o=arguments.length,c=new Array(o),e=0;e<o;e++)c[e]=arguments[e];return t=a.call.apply(a,[this].concat(c))||this,Object(p.a)(Object(r.a)(t),"handleLoadMore",d()((function(){t.props.dispatch(Object(O.z)(t.props.params.accountId))}),300,{leading:!0})),t}var c=o.prototype;return c.componentWillMount=function(){this.props.accountIds||(this.props.dispatch(Object(O.A)(this.props.params.accountId)),this.props.dispatch(Object(O.D)(this.props.params.accountId)))},c.componentWillReceiveProps=function(a){a.params.accountId!==this.props.params.accountId&&a.params.accountId&&(this.props.dispatch(Object(O.A)(a.params.accountId)),this.props.dispatch(Object(O.D)(a.params.accountId)))},c.render=function(){var a=this.props,t=a.shouldUpdateScroll,o=a.accountIds,c=a.hasMore,e=a.blockedBy,n=a.isAccount,r=a.multiColumn;if(!n)return Object(s.a)(w.a,{},void 0,Object(s.a)(A.a,{}));if(!o)return Object(s.a)(w.a,{},void 0,Object(s.a)(I.a,{}));var i=e?Object(s.a)(y.b,{id:"empty_column.account_unavailable",defaultMessage:"Profile unavailable"}):Object(s.a)(y.b,{id:"account.follows.empty",defaultMessage:"This user doesn't follow anyone yet."});return(Object(s.a)(w.a,{},void 0,Object(s.a)(M.a,{multiColumn:r}),Object(s.a)(k.a,{scrollKey:"following",hasMore:c,onLoadMore:this.handleLoadMore,shouldUpdateScroll:t,prepend:Object(s.a)(g.a,{accountId:this.props.params.accountId,hideTabs:!0}),alwaysPrepend:!0,emptyMessage:i,bindToDocument:!r},void 0,e?[]:o.map((function(a){return Object(s.a)(v.a,{id:a,withNote:!1},a)})))))},o}(b.a),Object(p.a)(e,"propTypes",{params:m.a.object.isRequired,dispatch:m.a.func.isRequired,shouldUpdateScroll:m.a.func,accountIds:j.a.list,hasMore:m.a.bool,blockedBy:m.a.bool,isAccount:m.a.bool,multiColumn:m.a.bool}),c=n))||c}}]);
//# sourceMappingURL=following.js.map