module Skim
  module React
    class CodeAttributes < Slim::Filter
      define_options :merge_attrs

      ATTR_NAMES = Hash[*(%w(
        accept acceptCharset accessKey action allowFullScreen allowTransparency alt
        async autoComplete autoFocus autoPlay capture cellPadding cellSpacing charSet
        challenge checked classID className cols colSpan content contentEditable contextMenu
        controls coords crossOrigin data dateTime defer dir disabled download draggable
        encType form formAction formEncType formMethod formNoValidate formTarget frameBorder
        headers height hidden high href hrefLang htmlFor httpEquiv icon id inputMode
        keyParams keyType label lang list loop low manifest marginHeight marginWidth max
        maxLength media mediaGroup method min minlength multiple muted name noValidate open
        optimum pattern placeholder poster preload radioGroup readOnly rel required role
        rows rowSpan sandbox scope scoped scrolling seamless selected shape size sizes
        span spellCheck src srcDoc srcSet start step style summary tabIndex target title
        type useMap value width wmode wrap
        autoCapitalize autoCorrect
        property
        itemProp itemScope itemType itemRef itemID
        unselectable
        results autoSave
        dangerouslySetInnerHTML
        clipPath cx cy d dx dy fill fillOpacity fontFamily
        fontSize fx fy gradientTransform gradientUnits markerEnd
        markerMid markerStart offset opacity patternContentUnits
        patternUnits points preserveAspectRatio r rx ry spreadMethod
        stopColor stopOpacity stroke  strokeDasharray strokeLinecap
        strokeOpacity strokeWidth textAnchor transform version
        viewBox x1 x2 x xlinkActuate xlinkArcrole xlinkHref xlinkRole
        xlinkShow xlinkTitle xlinkType xmlBase xmlLang xmlSpace y1 y2 y
      ).map {|name| [name.downcase, name]}.flatten)]

      def on_html_attrs(*attrs)
        return [:html, :attrs, *attrs.map {|attr| compile(attr) }]
      end

      def on_html_attr(name, value)
        @attr = name
        if found_name = ATTR_NAMES[name.downcase]
          name = found_name
        end
        super
      end

      def on_slim_attrvalue(escape, code)
        if delimiter = options[:merge_attrs][@attr]
          [:code, "@mergeValues(#{code}, #{escape}, #{delimiter.inspect})"]
        else
          [:escape, escape, [:dynamic, code]]
        end
      end
    end
  end
end
