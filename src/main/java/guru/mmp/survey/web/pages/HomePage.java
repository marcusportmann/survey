/*
 * Copyright 2016 Marcus Portmann
 * All rights reserved.
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package guru.mmp.survey.web.pages;

import guru.mmp.application.web.pages.AnonymousOnlyWebPage;
import guru.mmp.application.web.template.pages.TemplateWebPage;

/**
 * The <code>HomePage</code> class implements the "Home"
 * page for the web application.
 */
@AnonymousOnlyWebPage
public class HomePage 
  extends TemplateWebPage
{
  private static final long serialVersionUID = 1000000;

  /**
   * Constructs a new <code>HomePage</code>.
   */
  public HomePage()
  {
    super("Home");
  }
}
