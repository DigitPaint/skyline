/**
 * $Id: EditorCommands.js 1070 2009-04-01 18:03:06Z spocke $
 *
 * @author Moxiecode
 * @copyright Copyright � 2004-2008, Moxiecode Systems AB, All rights reserved.
 */

(function(tinymce) {
	var each = tinymce.each, isIE = tinymce.isIE, isGecko = tinymce.isGecko, isOpera = tinymce.isOpera, isWebKit = tinymce.isWebKit;

	/**
	 * This is a internal class and no method in this class should be called directly form the out side.
	 */
	tinymce.create('tinymce.EditorCommands', {
		EditorCommands : function(ed) {
			this.editor = ed;
		},

		execCommand : function(cmd, ui, val) {
			var t = this, ed = t.editor, f;

			switch (cmd) {
				// Ignore these
				case 'mceResetDesignMode':
				case 'mceBeginUndoLevel':
					return true;

				// Ignore these
				case 'unlink':
					t.UnLink();
					return true;

				// Bundle these together
				case 'JustifyLeft':
				case 'JustifyCenter':
				case 'JustifyRight':
				case 'JustifyFull':
					t.mceJustify(cmd, cmd.substring(7).toLowerCase());
					return true;

				default:
					f = this[cmd];

					if (f) {
						f.call(this, ui, val);
						return true;
					}
			}

			return false;
		},

		Indent : function() {
			var ed = this.editor, d = ed.dom, s = ed.selection, e, iv, iu;

			// Setup indent level
			iv = ed.settings.indentation;
			iu = /[a-z%]+$/i.exec(iv);
			iv = parseInt(iv);

			if (ed.settings.inline_styles && (!this.queryStateInsertUnorderedList() && !this.queryStateInsertOrderedList())) {
				each(s.getSelectedBlocks(), function(e) {
					d.setStyle(e, 'paddingLeft', (parseInt(e.style.paddingLeft || 0) + iv) + iu);
				});

				return;
			}

			ed.getDoc().execCommand('Indent', false, null);

			if (isIE) {
				d.getParent(s.getNode(), function(n) {
					if (n.nodeName == 'BLOCKQUOTE') {
						n.dir = n.style.cssText = '';
					}
				});
			}
		},

		Outdent : function() {
			var ed = this.editor, d = ed.dom, s = ed.selection, e, v, iv, iu;

			// Setup indent level
			iv = ed.settings.indentation;
			iu = /[a-z%]+$/i.exec(iv);
			iv = parseInt(iv);

			if (ed.settings.inline_styles && (!this.queryStateInsertUnorderedList() && !this.queryStateInsertOrderedList())) {
				each(s.getSelectedBlocks(), function(e) {
					v = Math.max(0, parseInt(e.style.paddingLeft || 0) - iv);
					d.setStyle(e, 'paddingLeft', v ? v + iu : '');
				});

				return;
			}

			ed.getDoc().execCommand('Outdent', false, null);
		},

/*
		mceSetAttribute : function(u, v) {
			var ed = this.editor, d = ed.dom, e;

			if (e = d.getParent(ed.selection.getNode(), d.isBlock))
				d.setAttrib(e, v.name, v.value);
		},
*/
		mceSetContent : function(u, v) {
			this.editor.setContent(v);
		},

		mceToggleVisualAid : function() {
			var ed = this.editor;

			ed.hasVisual = !ed.hasVisual;
			ed.addVisual();
		},

		mceReplaceContent : function(u, v) {
			var s = this.editor.selection;

			s.setContent(v.replace(/\{\$selection\}/g, s.getContent({format : 'text'})));
		},

		mceInsertLink : function(u, v) {
			var ed = this.editor, s = ed.selection, e = ed.dom.getParent(s.getNode(), 'a');

			if (tinymce.is(v, 'string'))
				v = {href : v};

			function set(e) {
				each(v, function(v, k) {
					ed.dom.setAttrib(e, k, v);
				});
			};

			if (!e) {
				ed.execCommand('CreateLink', false, 'javascript:mctmp(0);');
				each(ed.dom.select('a[href=javascript:mctmp(0);]'), function(e) {
					set(e);
				});
			} else {
				if (v.href)
					set(e);
				else
					ed.dom.remove(e, 1);
			}
		},

		UnLink : function() {
			var ed = this.editor, s = ed.selection;

			if (s.isCollapsed())
				s.select(s.getNode());

			ed.getDoc().execCommand('unlink', false, null);
			s.collapse(0);
		},

		FontName : function(u, v) {
			var t = this, ed = t.editor, s = ed.selection, e;

			if (!v) {
				if (s.isCollapsed())
					s.select(s.getNode());
			} else {
				if (ed.settings.convert_fonts_to_spans)
					t._applyInlineStyle('span', {style : {fontFamily : v}});
				else
					ed.getDoc().execCommand('FontName', false, v);
			}
		},

		FontSize : function(u, v) {
			var ed = this.editor, s = ed.settings, fc, fs;

			// Use style options instead
			if (s.convert_fonts_to_spans && v >= 1 && v <= 7) {
				fs = tinymce.explode(s.font_size_style_values);
				fc = tinymce.explode(s.font_size_classes);

				if (fc)
					v = fc[v - 1] || v;
				else
					v = fs[v - 1] || v;
			}

			if (v >= 1 && v <= 7)
				ed.getDoc().execCommand('FontSize', false, v);
			else
				this._applyInlineStyle('span', {style : {fontSize : v}});
		},

		queryCommandValue : function(c) {
			var f = this['queryValue' + c];

			if (f)
				return f.call(this, c);

			return false;
		},

		queryCommandState : function(cmd) {
			var f;

			switch (cmd) {
				// Bundle these together
				case 'JustifyLeft':
				case 'JustifyCenter':
				case 'JustifyRight':
				case 'JustifyFull':
					return this.queryStateJustify(cmd, cmd.substring(7).toLowerCase());

				default:
					if (f = this['queryState' + cmd])
						return f.call(this, cmd);
			}

			return -1;
		},

		_queryState : function(c) {
			try {
				return this.editor.getDoc().queryCommandState(c);
			} catch (ex) {
				// Ignore exception
			}
		},

		_queryVal : function(c) {
			try {
				return this.editor.getDoc().queryCommandValue(c);
			} catch (ex) {
				// Ignore exception
			}
		},

		queryValueFontSize : function() {
			var ed = this.editor, v = 0, p;

			if (p = ed.dom.getParent(ed.selection.getNode(), 'span'))
				v = p.style.fontSize;

			if (!v && (isOpera || isWebKit)) {
				if (p = ed.dom.getParent(ed.selection.getNode(), 'font'))
					v = p.size;

				return v;
			}

			return v || this._queryVal('FontSize');
		},

		queryValueFontName : function() {
			var ed = this.editor, v = 0, p;

			if (p = ed.dom.getParent(ed.selection.getNode(), 'font'))
				v = p.face;

			if (p = ed.dom.getParent(ed.selection.getNode(), 'span'))
				v = p.style.fontFamily.replace(/, /g, ',').replace(/[\'\"]/g, '').toLowerCase();

			if (!v)
				v = this._queryVal('FontName');

			return v;
		},

		mceJustify : function(c, v) {
			var ed = this.editor, se = ed.selection, n = se.getNode(), nn = n.nodeName, bl, nb, dom = ed.dom, rm;

			if (ed.settings.inline_styles && this.queryStateJustify(c, v))
				rm = 1;

			bl = dom.getParent(n, ed.dom.isBlock);

			if (nn == 'IMG') {
				if (v == 'full')
					return;

				if (rm) {
					if (v == 'center')
						dom.setStyle(bl || n.parentNode, 'textAlign', '');

					dom.setStyle(n, 'float', '');
					this.mceRepaint();
					return;
				}

				if (v == 'center') {
					// Do not change table elements
					if (bl && /^(TD|TH)$/.test(bl.nodeName))
						bl = 0;

					if (!bl || bl.childNodes.length > 1) {
						nb = dom.create('p');
						nb.appendChild(n.cloneNode(false));

						if (bl)
							dom.insertAfter(nb, bl);
						else
							dom.insertAfter(nb, n);

						dom.remove(n);
						n = nb.firstChild;
						bl = nb;
					}

					dom.setStyle(bl, 'textAlign', v);
					dom.setStyle(n, 'float', '');
				} else {
					dom.setStyle(n, 'float', v);
					dom.setStyle(bl || n.parentNode, 'textAlign', '');
				}

				this.mceRepaint();
				return;
			}

			// Handle the alignment outselfs, less quirks in all browsers
			if (ed.settings.inline_styles && ed.settings.forced_root_block) {
				if (rm)
					v = '';

				each(se.getSelectedBlocks(dom.getParent(se.getStart(), dom.isBlock), dom.getParent(se.getEnd(), dom.isBlock)), function(e) {
					dom.setAttrib(e, 'align', '');
					dom.setStyle(e, 'textAlign', v == 'full' ? 'justify' : v);
				});

				return;
			} else if (!rm)
				ed.getDoc().execCommand(c, false, null);

			if (ed.settings.inline_styles) {
				if (rm) {
					dom.getParent(ed.selection.getNode(), function(n) {
						if (n.style && n.style.textAlign)
							dom.setStyle(n, 'textAlign', '');
					});

					return;
				}

				each(dom.select('*'), function(n) {
					var v = n.align;

					if (v) {
						if (v == 'full')
							v = 'justify';

						dom.setStyle(n, 'textAlign', v);
						dom.setAttrib(n, 'align', '');
					}
				});
			}
		},

		mceSetCSSClass : function(u, v) {
			this.mceSetStyleInfo(0, {command : 'setattrib', name : 'class', value : v});
		},

		getSelectedElement : function() {
			var t = this, ed = t.editor, dom = ed.dom, se = ed.selection, r = se.getRng(), r1, r2, sc, ec, so, eo, e, sp, ep, re;

			if (se.isCollapsed() || r.item)
				return se.getNode();

			// Setup regexp
			re = ed.settings.merge_styles_invalid_parents;
			if (tinymce.is(re, 'string'))
				re = new RegExp(re, 'i');

			if (isIE) {
				r1 = r.duplicate();
				r1.collapse(true);
				sc = r1.parentElement();

				r2 = r.duplicate();
				r2.collapse(false);
				ec = r2.parentElement();

				if (sc != ec) {
					r1.move('character', 1);
					sc = r1.parentElement();
				}

				if (sc == ec) {
					r1 = r.duplicate();
					r1.moveToElementText(sc);

					if (r1.compareEndPoints('StartToStart', r) == 0 && r1.compareEndPoints('EndToEnd', r) == 0)
						return re && re.test(sc.nodeName) ? null : sc;
				}
			} else {
				function getParent(n) {
					return dom.getParent(n, '*');
				};

				sc = r.startContainer;
				ec = r.endContainer;
				so = r.startOffset;
				eo = r.endOffset;

				if (!r.collapsed) {
					if (sc == ec) {
						if (so - eo < 2) {
							if (sc.hasChildNodes()) {
								sp = sc.childNodes[so];
								return re && re.test(sp.nodeName) ? null : sp;
							}
						}
					}
				}

				if (sc.nodeType != 3 || ec.nodeType != 3)
					return null;

				if (so == 0) {
					sp = getParent(sc);

					if (sp && sp.firstChild != sc)
						sp = null;
				}

				if (so == sc.nodeValue.length) {
					e = sc.nextSibling;

					if (e && e.nodeType == 1)
						sp = sc.nextSibling;
				}

				if (eo == 0) {
					e = ec.previousSibling;

					if (e && e.nodeType == 1)
						ep = e;
				}

				if (eo == ec.nodeValue.length) {
					ep = getParent(ec);

					if (ep && ep.lastChild != ec)
						ep = null;
				}

				// Same element
				if (sp == ep)
					return re && sp && re.test(sp.nodeName) ? null : sp;
			}

			return null;
		},

		mceSetStyleInfo : function(u, v) {
			var t = this, ed = t.editor, d = ed.getDoc(), dom = ed.dom, e, b, s = ed.selection, nn = v.wrapper || 'span', b = s.getBookmark(), re;

			function set(n, e) {
				if (n.nodeType == 1) {
					switch (v.command) {
						case 'setattrib':
							return dom.setAttrib(n, v.name, v.value);

						case 'setstyle':
							return dom.setStyle(n, v.name, v.value);

						case 'removeformat':
							return dom.setAttrib(n, 'class', '');
					}
				}
			};

			// Setup regexp
			re = ed.settings.merge_styles_invalid_parents;
			if (tinymce.is(re, 'string'))
				re = new RegExp(re, 'i');

			// Set style info on selected element
			if ((e = t.getSelectedElement()) && !ed.settings.force_span_wrappers)
				set(e, 1);
			else {
				// Generate wrappers and set styles on them
				d.execCommand('FontName', false, '__');
				each(dom.select('span,font'), function(n) {
					var sp, e;

					if (dom.getAttrib(n, 'face') == '__' || n.style.fontFamily === '__') {
						sp = dom.create(nn, {mce_new : '1'});

						set(sp);

						each (n.childNodes, function(n) {
							sp.appendChild(n.cloneNode(true));
						});

						dom.replace(sp, n);
					}
				});
			}

			// Remove wrappers inside new ones
			each(dom.select(nn).reverse(), function(n) {
				var p = n.parentNode;

				// Check if it's an old span in a new wrapper
				if (!dom.getAttrib(n, 'mce_new')) {
					// Find new wrapper
					p = dom.getParent(n, '*[mce_new]');

					if (p)
						dom.remove(n, 1);
				}
			});

			// Merge wrappers with parent wrappers
			each(dom.select(nn).reverse(), function(n) {
				var p = n.parentNode;

				if (!p || !dom.getAttrib(n, 'mce_new'))
					return;

				if (ed.settings.force_span_wrappers && p.nodeName != 'SPAN')
					return;

				// Has parent of the same type and only child
				if (p.nodeName == nn.toUpperCase() && p.childNodes.length == 1)
					return dom.remove(p, 1);

				// Has parent that is more suitable to have the class and only child
				if (n.nodeType == 1 && (!re || !re.test(p.nodeName)) && p.childNodes.length == 1) {
					set(p); // Set style info on parent instead
					dom.setAttrib(n, 'class', '');
				}
			});

			// Remove empty wrappers
			each(dom.select(nn).reverse(), function(n) {
				if (dom.getAttrib(n, 'mce_new') || (dom.getAttribs(n).length <= 1 && n.className === '')) {
					if (!dom.getAttrib(n, 'class') && !dom.getAttrib(n, 'style'))
						return dom.remove(n, 1);

					dom.setAttrib(n, 'mce_new', ''); // Remove mce_new marker
				}
			});

			s.moveToBookmark(b);
		},

		queryStateJustify : function(c, v) {
			var ed = this.editor, n = ed.selection.getNode(), dom = ed.dom;

			if (n && n.nodeName == 'IMG') {
				if (dom.getStyle(n, 'float') == v)
					return 1;

				return n.parentNode.style.textAlign == v;
			}

			n = dom.getParent(ed.selection.getStart(), function(n) {
				return n.nodeType == 1 && n.style.textAlign;
			});

			if (v == 'full')
				v = 'justify';

			if (ed.settings.inline_styles)
				return (n && n.style.textAlign == v);

			return this._queryState(c);
		},

		ForeColor : function(ui, v) {
			var ed = this.editor;

			if (ed.settings.convert_fonts_to_spans) {
				this._applyInlineStyle('span', {style : {color : v}});
				return;
			} else
				ed.getDoc().execCommand('ForeColor', false, v);
		},

		HiliteColor : function(ui, val) {
			var t = this, ed = t.editor, d = ed.getDoc();

			if (ed.settings.convert_fonts_to_spans) {
				this._applyInlineStyle('span', {style : {backgroundColor : val}});
				return;
			}

			function set(s) {
				if (!isGecko)
					return;

				try {
					// Try new Gecko method
					d.execCommand("styleWithCSS", 0, s);
				} catch (ex) {
					// Use old
					d.execCommand("useCSS", 0, !s);
				}
			};

			if (isGecko || isOpera) {
				set(true);
				d.execCommand('hilitecolor', false, val);
				set(false);
			} else
				d.execCommand('BackColor', false, val);
		},

		FormatBlock : function(ui, val) {
			var t = this, ed = t.editor, s = ed.selection, dom = ed.dom, bl, nb, b;

			function isBlock(n) {
				return /^(P|DIV|H[1-6]|ADDRESS|BLOCKQUOTE|PRE)$/.test(n.nodeName);
			};

			bl = dom.getParent(s.getNode(), function(n) {
				return isBlock(n);
			});

			// IE has an issue where it removes the parent div if you change format on the paragrah in <div><p>Content</p></div>
			// FF and Opera doesn't change parent DIV elements if you switch format
			if (bl) {
				if ((isIE && isBlock(bl.parentNode)) || bl.nodeName == 'DIV') {
					// Rename block element
					nb = ed.dom.create(val);

					each(dom.getAttribs(bl), function(v) {
						dom.setAttrib(nb, v.nodeName, dom.getAttrib(bl, v.nodeName));
					});

					b = s.getBookmark();
					dom.replace(nb, bl, 1);
					s.moveToBookmark(b);
					ed.nodeChanged();
					return;
				}
			}

			val = ed.settings.forced_root_block ? (val || '<p>') : val;

			if (val.indexOf('<') == -1)
				val = '<' + val + '>';

			if (tinymce.isGecko)
				val = val.replace(/<(div|blockquote|code|dt|dd|dl|samp)>/gi, '$1');

			ed.getDoc().execCommand('FormatBlock', false, val);
		},

		mceCleanup : function() {
			var ed = this.editor, s = ed.selection, b = s.getBookmark();
			ed.setContent(ed.getContent());
			s.moveToBookmark(b);
		},

		mceRemoveNode : function(ui, val) {
			var ed = this.editor, s = ed.selection, b, n = val || s.getNode();

			// Make sure that the body node isn't removed
			if (n == ed.getBody())
				return;

			b = s.getBookmark();
			ed.dom.remove(n, 1);
			s.moveToBookmark(b);
			ed.nodeChanged();
		},

		mceSelectNodeDepth : function(ui, val) {
			var ed = this.editor, s = ed.selection, c = 0;

			ed.dom.getParent(s.getNode(), function(n) {
				if (n.nodeType == 1 && c++ == val) {
					s.select(n);
					ed.nodeChanged();
					return false;
				}
			}, ed.getBody());
		},

		mceSelectNode : function(u, v) {
			this.editor.selection.select(v);
		},

		mceInsertContent : function(ui, val) {
			this.editor.selection.setContent(val);
		},

		mceInsertRawHTML : function(ui, val) {
			var ed = this.editor;

			ed.selection.setContent('tiny_mce_marker');
			ed.setContent(ed.getContent().replace(/tiny_mce_marker/g, val));
		},

		mceRepaint : function() {
			var s, b, e = this.editor;

			if (tinymce.isGecko) {
				try {
					s = e.selection;
					b = s.getBookmark(true);

					if (s.getSel())
						s.getSel().selectAllChildren(e.getBody());

					s.collapse(true);
					s.moveToBookmark(b);
				} catch (ex) {
					// Ignore
				}
			}
		},

		queryStateUnderline : function() {
			var ed = this.editor, n = ed.selection.getNode();

			if (n && n.nodeName == 'A')
				return false;

			return this._queryState('Underline');
		},

		queryStateOutdent : function() {
			var ed = this.editor, n;

			if (ed.settings.inline_styles) {
				if ((n = ed.dom.getParent(ed.selection.getStart(), ed.dom.isBlock)) && parseInt(n.style.paddingLeft) > 0)
					return true;

				if ((n = ed.dom.getParent(ed.selection.getEnd(), ed.dom.isBlock)) && parseInt(n.style.paddingLeft) > 0)
					return true;
			}

			return this.queryStateInsertUnorderedList() || this.queryStateInsertOrderedList() || (!ed.settings.inline_styles && !!ed.dom.getParent(ed.selection.getNode(), 'BLOCKQUOTE'));
		},

		queryStateInsertUnorderedList : function() {
			return this.editor.dom.getParent(this.editor.selection.getNode(), 'UL');
		},

		queryStateInsertOrderedList : function() {
			return this.editor.dom.getParent(this.editor.selection.getNode(), 'OL');
		},

		queryStatemceBlockQuote : function() {
			return !!this.editor.dom.getParent(this.editor.selection.getStart(), function(n) {return n.nodeName === 'BLOCKQUOTE';});
		},

		_applyInlineStyle : function(na, at, op) {
			var t = this, ed = t.editor, dom = ed.dom, bm, lo = {}, kh, found;

			na = na.toUpperCase();

			if (op && op.check_classes && at['class'])
				op.check_classes.push(at['class']);

			function removeEmpty() {
				each(dom.select(na).reverse(), function(n) {
					var c = 0;

					// Check if there is any attributes
					each(dom.getAttribs(n), function(an) {
						if (an.nodeName.substring(0, 1) != '_' && dom.getAttrib(n, an.nodeName) != '') {
							//console.log(dom.getOuterHTML(n), dom.getAttrib(n, an.nodeName));
							c++;
						}
					});

					// No attributes then remove the element and keep the children
					if (c == 0)
						dom.remove(n, 1);
				});
			};

			function replaceFonts() {
				var bm;

				each(dom.select('span,font'), function(n) {
					if (n.style.fontFamily == 'mceinline' || n.face == 'mceinline') {
						if (!bm)
							bm = ed.selection.getBookmark();

						at._mce_new = '1';
						dom.replace(dom.create(na, at), n, 1);
					}
				});

				// Remove redundant elements
				each(dom.select(na + '[_mce_new]'), function(n) {
					function removeStyle(n) {
						if (n.nodeType == 1) {
							each(at.style, function(v, k) {
								dom.setStyle(n, k, '');
							});

							// Remove spans with the same class or marked classes
							if (at['class'] && n.className && op) {
								each(op.check_classes, function(c) {
									if (dom.hasClass(n, c))
										dom.removeClass(n, c);
								});
							}
						}
					};

					// Remove specified style information from child elements
					each(dom.select(na, n), removeStyle);

					// Remove the specified style information on parent if current node is only child (IE)
					if (n.parentNode && n.parentNode.nodeType == 1 && n.parentNode.childNodes.length == 1)
						removeStyle(n.parentNode);

					// Remove the child elements style info if a parent already has it
					dom.getParent(n.parentNode, function(pn) {
						if (pn.nodeType == 1) {
							if (at.style) {
								each(at.style, function(v, k) {
									var sv;

									if (!lo[k] && (sv = dom.getStyle(pn, k))) {
										if (sv === v)
											dom.setStyle(n, k, '');

										lo[k] = 1;
									}
								});
							}

							// Remove spans with the same class or marked classes
							if (at['class'] && pn.className && op) {
								each(op.check_classes, function(c) {
									if (dom.hasClass(pn, c))
										dom.removeClass(n, c);
								});
							}
						}

						return false;
					});

					n.removeAttribute('_mce_new');
				});

				removeEmpty();
				ed.selection.moveToBookmark(bm);

				return !!bm;
			};

			// Create inline elements
			ed.focus();
			ed.getDoc().execCommand('FontName', false, 'mceinline');
			replaceFonts();

			if (kh = t._applyInlineStyle.keyhandler) {
				ed.onKeyUp.remove(kh);
				ed.onKeyPress.remove(kh);
				ed.onKeyDown.remove(kh);
				ed.onSetContent.remove(t._applyInlineStyle.chandler);
			}

			if (ed.selection.isCollapsed()) {
				// IE will format the current word so this code can't be executed on that browser
				if (!isIE) {
					each(dom.getParents(ed.selection.getNode(), 'span'), function(n) {
						each(at.style, function(v, k) {
							var kv;

							if (kv = dom.getStyle(n, k)) {
								if (kv == v) {
									dom.setStyle(n, k, '');
									found = 2;
									return false;
								}

								found = 1;
								return false;
							}
						});

						if (found)
							return false;
					});

					if (found == 2) {
						bm = ed.selection.getBookmark();

						removeEmpty();

						ed.selection.moveToBookmark(bm);

						// Node change needs to be detached since the onselect event
						// for the select box will run the onclick handler after onselect call. Todo: Add a nicer fix!
						window.setTimeout(function() {
							ed.nodeChanged();
						}, 1);

						return;
					}
				}

				// Start collecting styles
				t._pendingStyles = tinymce.extend(t._pendingStyles || {}, at.style);

				t._applyInlineStyle.chandler = ed.onSetContent.add(function() {
					delete t._pendingStyles;
				});

				t._applyInlineStyle.keyhandler = kh = function(e) {
					// Use pending styles
					if (t._pendingStyles) {
						at.style = t._pendingStyles;
						delete t._pendingStyles;
					}

					if (replaceFonts()) {
						ed.onKeyDown.remove(t._applyInlineStyle.keyhandler);
						ed.onKeyPress.remove(t._applyInlineStyle.keyhandler);
					}

					if (e.type == 'keyup')
						ed.onKeyUp.remove(t._applyInlineStyle.keyhandler);
				};

				ed.onKeyDown.add(kh);
				ed.onKeyPress.add(kh);
				ed.onKeyUp.add(kh);
			} else
				t._pendingStyles = 0;
		}
	});
})(tinymce);